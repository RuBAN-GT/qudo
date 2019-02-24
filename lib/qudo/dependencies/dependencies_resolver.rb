# frozen_string_literal: true

require 'qudo/dependencies/dependencies_store'

module Qudo
  module Dependencies
    # Special resolver for different sources
    module DependenciesResolver
      class << self
        # Generate a dependencies register
        #
        # @return [DependenciesStore]
        def build_dependencies_store
          DependenciesStore.new
        end

        # Load required dependencies from selected register
        #
        # @param  [Hash] dependencies
        # @param  [Array<String,Symbol>] requirements
        # @return [DependenciesStore]
        def retrieve(dependencies, requirements = [])
          requirements.each_with_object(build_dependencies_store) do |requirement, total|
            total[requirement] = retrieve_dependency(dependencies, requirement)
          end.freeze
        end

        # Retrieve dependency from manager
        #
        # @param  [Hash]          dependencies
        # @param  [String,Symbol] key
        # @return [*]
        def retrieve_dependency(dependencies, key)
          raise ArgumentError, "Dependency #{key} is not found" unless dependencies.key?(key)

          dependencies[key]
        end

        # Resolve required dependencies from register
        #
        # @param  [Hashie::Mash] dependencies
        # @param  [Array<String,Symbol>] requirements
        # @return [DependenciesStore]
        def resolve(dependencies, requirements = [])
          retrieved = retrieve(dependencies, requirements)
          retrieved.each_with_object(build_dependencies_store) do |(k, v), total|
            total[k] = resolve_dependency v
          end.freeze
        end

        # Resolve dependency
        #
        # @param  [Qudo::Component] dependency
        # @return [*]
        def resolve_dependency(dependency)
          return dependency.resolve if dependency.respond_to? :resolve
          return dependency.call if dependency.respond_to? :call

          raise ArgumentError, 'Unknown dependency for resolving'
        end
      end
    end
  end
end
