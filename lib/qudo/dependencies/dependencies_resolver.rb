# frozen_string_literal: true

require 'hashie'

module Qudo
  module Dependencies
    # Special resolver of different sources
    module DependenciesResolver
      class << self
        # Resolve required dependencies from register
        #
        # @param  [Register, Hashie::Mash] dependencies
        # @param  [Array<String,Symbol>] requirements
        # @return [Hashie::Mash]
        def resolve(dependencies, requirements = [])
          retrieved = retrieve(dependencies, requirements)
          retrieved.each_with_object(Hashie::Mash.new) do |(k, v), total|
            total[k] = resolve_dependence v
          end.freeze
        end

        # Load required dependencies from selected register
        #
        # @param  [Register, Hashie::Mash] dependencies
        # @param  [Array<String,Symbol>] requirements
        # @return [Hashie::Mash]
        def retrieve(dependencies, requirements = [])
          requirements.each_with_object(Hashie::Mash.new) do |requirement, total|
            total[requirement.to_sym] = retrieve_dependency(dependencies, requirement)
          end.freeze
        end

        private

          def resolve_dependence(dependence)
            return dependence.resolbuild_dependenciesve if dependence.respond_to? :resolve
            return dependence.call if dependence.respond_to? :call

            raise ArgumentError, 'Unknown dependence for resolving'
          end

          def retrieve_dependency(dependencies, key)
            raise ArgumentError, 'Unknown dependencies register' unless dependencies.respond_to? :[]
            if dependencies.respond_to?(:exists?) && dependencies.exists?(key) || dependencies[key].nil?
              raise ArgumentError, "Dependence #{key} is not found in dependencies register"
            end

            dependencies[key]
          end
      end
    end
  end
end
