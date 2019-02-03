# frozen_string_literal: true

require 'hooks'

module Qudo
  # The object factory for safe creation and utilization objects
  class ObjectFactory
    include Hooks

    attr_reader  :build_args, :target
    define_hooks :before_build, :after_build, :before_finalize, :after_finalize

    class << self
      # The main logic for component target initialization
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

    # Get target with building if it needed
    #
    # @return [*] from builder
    def resolve
      built? ? target : build
    end

    # Run build workflow for setting up target object
    # @note For built target this method bind him to finalizer
    #
    # @return [*] from builder
    # @raise [StandardError] when builder is undefined
    # @raise [StandardError] when target is already built
    def build
      raise 'The target already built' if built?
      raise 'Undefined component builder' if self.class.builder.nil?

      run_hook :before_build
      build_target
      run_hook :after_build

      handle_finalizer
      target
    end

    # Run destruction workflow for target
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
