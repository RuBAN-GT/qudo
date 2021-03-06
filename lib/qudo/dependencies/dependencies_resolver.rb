# frozen_string_literal: true

require 'hashie'

module Qudo
  module Dependencies
    # Special resolver for different sources
    module DependenciesResolver
      class << self
        # Load required dependencies from selected register
        #
        # @param  [Hash] dependencies
        # @param  [Array<String,Symbol>] requirements
        # @return [Hashie::Mash]
        def retrieve(dependencies, requirements = [])
          requirements.each_with_object(Hashie::Mash.new) do |requirement, total|
            total[requirement] = retrieve_dependency(dependencies, requirement)
          end.freeze
        end

        # Retrieve dependency from manager
        #
        # @param  [Hash]          dependencies
        # @param  [String,Symbol] key
        # @return [*]
        def retrieve_dependency(dependencies, key)
          raise ArgumentError, "dependency #{key} is not found" unless dependencies.key?(key)

          dependencies[key]
        end

        # Resolve required dependencies from register
        #
        # @param  [Hashie::Mash] dependencies
        # @param  [Array<String,Symbol>] requirements
        # @return [Hashie::Mash]
        def resolve(dependencies, requirements = [])
          retrieved = retrieve(dependencies, requirements)
          retrieved.each_with_object(Hashie::Mash.new) do |(k, v), total|
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
