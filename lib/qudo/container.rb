# frozen_string_literal: true

require 'hashie'
require 'qudo/dependencies/dependencies_builder'

module Qudo
  # The simple register over components
  class Container
    def initialize
      @store = Hashie::Mash.new
    end

    def components
      @store.dup
    end

    def register(name, *args)
      store[name] = handle_component(*args)
    end

    def retrieve(name)
      store[name]
    end

    def [](name)
      retrieve name
    end

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
