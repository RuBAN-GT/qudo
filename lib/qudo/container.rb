# frozen_string_literal: true

require 'qudo/component'
require 'qudo/components/component_generator'
require 'qudo/utils/class_loader'
require 'qudo/utils/persistent_store'

module Qudo
  # The simple register over components
  #
  # @attr_reader [Utils::PersistentStore] store with components
  # @attr_reader [Utils::ClassLoader] class_loader for automatically loading components
  # @attr_reader [Components::ComponentGenerator] component_generator for initialize instances of components
  class Container
    attr_reader :store, :class_loader, :component_generator

    class << self
      def default_store
        Utils::PersistentStore
      end

      def default_class_loader
        Utils::ClassLoader.new
      end

      def default_component_generator
        Components::ComponentGenerator
      end
    end

    # Initializer
    #
    # @param [Hash] options with external dependencies
    #
    # @option options [Utils::PersistentStore]         :container_store
    # @option options [Utils::ClassLoader]             :class_loader
    # @option options [Components::ComponentGenerator] :component_generator
    def initialize(options = {})
      @store = options.fetch(:container_store, self.class.default_store).new

      @class_loader        = options.fetch :class_loader, self.class.default_class_loader
      @component_generator = options.fetch :component_generator, self.class.default_component_generator
    end

    # Safe components list
    #
    # @return [Utils::PersistentStore]
    def components
      @store.dup
    end

    # Load components from specific path
    #
    # @example Load classes from components/cache/redis.rb
    #   container.auto_register(
    #     Pathname.new(__dir__).join('components', '**', '*.rb')
    #   ) #=> { cache_redis: Cache::Redis }
    #
    # @param  [Pathname,String] path with a specification (mask) about sources
    # @return [Hash<Symbol,Component>]
    def auto_register(path)
      class_loader.call(path) do |key, klass|
        raise LoadError, 'Class must be inherits Component' unless klass < Component

        register key, klass
      end
    end

    # Save some component in the container store
    #
    # @param  [String,Symbol] name
    # @param  [Component,Class<Component>] input
    # @param  [Hash,Hashie] options for component options
    # @return [Qudo::Component]
    def register(name, input, options = {})
      store[name] = component_generator.call input, options.merge(dependencies: store)
    end
    alias []= register

    # Get component instance from store
    #
    # @param  [String,Symbol] name
    # @return [Component,nil]
    def retrieve(name)
      store[name]
    end

    def retrieve!(name)
      raise KeyError, "Undefined component #{name}" unless store.key? name

      retrieve name
    end

    # Get component resolved target from store
    #
    # @param  [String,Symbol] name
    # @return [*,nil]
    def resolve(name)
      return nil unless store.key? name

      retrieve(name).resolve
    end

    def resolve!(name)
      raise KeyError, "Undefined component #{name}" unless store.key? name

      resolve name
    end
    alias [] resolve!
  end
end
