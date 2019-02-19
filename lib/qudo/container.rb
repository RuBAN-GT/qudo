# frozen_string_literal: true

require 'qudo/dependencies/dependencies_builder'
require 'qudo/utils/class_loader'
require 'qudo/utils/persistent_store'

module Qudo
  # The simple register over components
  class Container
    def self.build_container_store(*args)
      Utils::PersistentStore.new(*args)
    end

    def initialize
      @store = self.class.build_container_store
    end

    def components
      @store.dup
    end

    def auto_register(path)
      Utils::ClassLoader.load_map(path) { |*args| register(*args) }
    end

    # Save some component in the container store
    #
    # @param  [String,Symbol] name
    # @return [Qudo::Component]
    def register(name, *args)
      store[name] = handle_component(*args)
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

    private

      attr_reader :store

      def handle_component(component, options = {})
        component.is_a?(Class) ? generate_new_component(component, options) : generate_injected_component(component)
      end

      def generate_new_component(component_klass, options = {})
        check_dependencies_builder! component_klass
        component_klass.new options.merge(dependencies: components)
      end

      def generate_injected_component(component)
        check_dependencies_builder! component.class
        component.inject_dependencies components unless component.dependencies_resolved?
        component
      end

      def check_dependencies_builder!(subject)
        unless subject.included_modules.include? Dependencies::DependenciesBuilder
          raise ArgumentError, 'Component class must include DependenciesBuilder module'
        end
      end
  end
end
