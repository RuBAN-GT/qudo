# frozen_string_literal: true

require 'hooks'
require 'qudo/utils/properties'

module Qudo
  # The object factory for safe creation and utilization objects
  #
  # Supports a Hooks definition: %i[before_build after_build before_finalize after_finalize]
  # @see https://github.com/apotonick/hooks
  #
  # @attr_reader [Array<*>] build_args with arguments for builder
  # @attr_reader [*] target that returned from builder
  class ObjectFactory
    include Hooks
    include Utils::Properties

    attr_reader  :build_args, :target
    define_hooks :before_build, :after_build, :before_finalize, :after_finalize

    # A flag that controls of automatic binding finalizer to a garbage collector
    property :auto_finalization, false

    class << self
      # A building logic for a component target initialization
      #
      # @abstract
      # @example some client initialization
      #   def builder
      #     DbClient.new
      #   end
      def builder(*_args)
        raise NotImplementedError
      end

      # The logic for utilisation of a target
      #
      # @abstract
      # @example closing connection before destroying object
      #   def finalizer(target)
      #     target.close!
      #   end
      #
      # @param [*] _target with built artifact
      def finalizer(_target); end
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
    #
    # @return [*] from builder
    def build
      return target if built?

      run_hook :before_build
      build_target
      run_hook :after_build

      bind_finalizer
      target
    end

    # A strict variant for #build method
    #
    # @return [#build]
    # @raise  [LoadError] when target is already built
    def build!
      raise LoadError, 'The target already built' if built?
      build
    end

    # Run destruction workflow for a target
    #
    # @return [void]
    def finalize
      return unless built?

      run_hook :before_finalize
      finalize_target
      run_hook :after_finalize
    end

    # A strict variant for #finalize method
    #
    # @return [#finalize]
    # @raise  [LoadError] when target is already built
    def finalize!
      raise LoadError, 'The target doesnt built' unless built?
      finalize
    end

    private

      def bind_finalizer
        return unless properties.auto_finalization?

        ObjectSpace.define_finalizer(target) { finalize }
      rescue StandardError
        raise 'Cannot use finalizer for the target'
      end

      def build_target
        @built  = true
        @target = self.class.builder(*build_args)
      end

      def finalize_target
        self.class.finalizer target
        reset_target
      end

      def reset_target
        @built  = false
        @target = nil
      end
  end
end
