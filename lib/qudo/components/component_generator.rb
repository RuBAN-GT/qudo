# frozen_string_literal: true

require 'qudo/dependencies/dependencies_builder'

module Qudo
  module Components
    # Wrapper over components for generation component instances
    # from other instances or classes
    module ComponentGenerator
      class << self
        # Save some component in the container store
        #
        # @param  [Qudo::Component,Class<Qudo::Component>] input
        # @param  [Hash,Hashie] options for component options
        # @return [Qudo::Component]
        def call(input, options = {})
          if input.is_a?(Class)
            generate_new_component(input, options)
          else
            dependencies = options.fetch(:dependencies, {})
            generate_injected_component(input, dependencies)
          end
        end

        def generate_new_component(component_klass, options = {})
          check_dependencies_builder! component_klass
          component_klass.new options
        end

        def generate_injected_component(component, dependencies = {})
          check_dependencies_builder! component.class
          component.inject_dependencies dependencies unless component.dependencies_resolved?
          component
        end

        private

          def check_dependencies_builder!(subject)
            unless subject.included_modules.include? Qudo::Dependencies::DependenciesBuilder
              raise ArgumentError, 'Component class must include DependenciesBuilder module'
            end
          end
      end
    end
  end
end
