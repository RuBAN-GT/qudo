# frozen_string_literal: true

require 'qudo/dependencies/dependencies_builder'

module Qudo
  module Components
    # Wrapper over components for generation component instances
    # from other instances or classes
    module ComponentGenerator
      class << self
        # Universal generation method for any inputs
        #
        # @overload call(input, dependencies)
        #   Generate a component with injection from instance
        #   @param [Qudo::Component] input
        #   @param [Hash] dependencies
        #
        # @overload call(input, options)
        #   Generate a component from class and options
        #   @param [Class<Qudo::Component>] input
        #   @param [Hash] options for initialization
        #
        # @return [Qudo::Component]
        def call(input, *args)
          method = input.is_a?(Class) ? :generate_new_component : :generate_injected_component
          send method, *args
        end

        def generate_new_component(component_klass, options = {})
          component_klass.new options
        end

        def generate_injected_component(component, dependencies = {})
          component.tap do |c|
            c.inject_dependencies dependencies if can_inject_dependencies?(c)
          end
        end

        private

          def can_inject_dependencies?(subject)
            subject.class.included_modules.include?(Qudo::Dependencies::DependenciesBuilder) && !subject.dependencies_resolved?
          end
      end
    end
  end
end
