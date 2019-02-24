# frozen_string_literal: true

require 'hooks'
require 'qudo/utils/properties'
require 'qudo/utils/store'

module Qudo
  # The object factory for safe creation and utilization objects
  #
  # Supports a Hooks definition: %i[before_build after_build before_finalize after_finalize]
  # @see https://github.com/apotonick/hooks
  #
  # @attr_reader [*] target that returned from builder
  class ObjectFactory
    include Hooks
    include Utils::Properties

    attr_reader  :target
    define_hooks :before_build, :after_build, :before_finalize, :after_finalize

    # A flag that controls of automatic binding finalizer to a garbage collector
    property :auto_finalization, false

    # Definition of a builder options store
    property :builder_opts_store, Utils::Store

    class << self
      # A building logic for a component target initialization
      #
      # @abstract
      # @example Some client initialization
      #   def builder(builder_opts)
      #     DbClient.new builder_opts.config
      #   end
      #
      # @param [Utils::Store] _options
      def builder(_options)
        raise NotImplementedError
      end

      # The logic for utilisation of a target
      #
      # @abstract
      # @example Closing connection before destroying object
      #   property :auto_finalization, true
      #
      #   def finalizer(target)
      #     target.close!
      #   end
      #
      # @param [*] _target with built artifact
      def finalizer(_target); end
    end

    # Options for .builder
    #
    # @return [Qudo::Utils::Store]
    def builder_opts
      @builder_opts ||= generate_builder_opts
    end

    # A factory already built a target
    #
    # @return [Boolean]
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
      end

      def build_target
        @built  = true
        @target = self.class.builder(builder_opts.freeze)
      end

      def finalize_target
        self.class.finalizer target
        reset_target
      end

      def generate_builder_opts
        properties.builder_opts_store.new
      end

      def reset_target
        @built  = false
        @target = nil
      end
  end
end
