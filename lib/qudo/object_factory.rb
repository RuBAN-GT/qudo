# frozen_string_literal: true

require 'hooks'

module Qudo
  # The object factory for safe creation and utilization objects
  #
  # Supports a Hooks definition: %w[before_build after_build before_finalize after_finalize]
  #
  # @attr_reader [Array<*>] build_args with arguments for builder
  # @attr_reader [*] target that returned from builder
  class ObjectFactory
    include Hooks

    attr_reader  :build_args, :target
    define_hooks :before_build, :after_build, :before_finalize, :after_finalize

    class << self
      # The building logic for a component target initialization
      #
      # @example some client initialization
      #   builder |*_|
      #     DbClient.new
      #   end
      #
      # @param  [Proc] block
      # @return [Proc,nil]
      def builder(&block)
        @builder ||= block
      end

      # The logic for utilisation of target object
      #
      # @example closing connection before destroying object
      #   finalizer do |target|
      #     target.close!
      #   end
      #
      # @param  [Hash] options
      # @option options [Boolean] :manual (false) disabling of auto-destruction of a target
      #
      # @param  [Proc] block
      # @return [Proc,nil]
      def finalizer(options = {}, &block)
        return @finalizer unless @finalizer.nil?

        @manual_finalizer = options.fetch :manual, false
        @finalizer        = block unless block.nil?
      end

      def manual_finalizer?
        @manual_finalizer ||= false
      end
    end

    def built?
      @built
    end

    # Get a target with calling of building process if it needed
    #
    # @return [*] from builder
    def resolve
      built? ? target : build
    end

    # Run build workflow for setting up target object
    # @note For built target this method bind him to finalizer
    #
    # @return [*] from builder
    # @raise [LoadError] when target is already built
    # @raise [LoadError] when builder is undefined
    def build
      raise LoadError, 'The target already built' if built?
      raise LoadError, 'Undefined component builder' if self.class.builder.nil?

      run_hook :before_build
      build_target
      run_hook :after_build

      handle_finalizer
      target
    end

    # Run destruction workflow for target
    #
    # @return [void]
    def finalize
      return unless built?

      run_hook :before_finalize
      self.class.finalizer&.call target
      run_hook :after_finalize

      reset_target
    end

    private

      def handle_finalizer
        bind_finalizer unless self.class.manual_finalizer?
      end

      def bind_finalizer
        ObjectSpace.define_finalizer(target) { finalize }
      rescue StandardError
        raise 'Cannot use finalizer for the target'
      end

      def build_target
        @built  = true
        @target = self.class.builder.call(*build_args)
      end

      def reset_target
        @built  = false
        @target = nil
      end
  end
end
