# frozen_string_literal: true

require 'qudo/dependencies/dependencies_resolver'

module Qudo
  module Dependencies
    # Extendable module for dependencies declaration and building
    module DependenciesBuilder
      # Methods for defining and building dependencies
      module BuilderModule
        # Dependencies declaration
        #
        # @param  [Array<String,Symbol>] dependencies
        # @return [Array<String,Symbol>]
        # @raise  [ArgumentError] when input is not Array
        def dependencies(dependencies = nil)
          return @dependencies if dependencies.nil?
          raise ArgumentError, 'Dependencies must be string/symbol array' unless dependencies.is_a? Array

          @dependencies = dependencies.clone
        end

        # Build dependencies from injectable argument
        #
        # @param  [Hash] manager
        # @return [DependenciesStore]
        def build_dependencies(manager)
          DependenciesResolver.resolve manager, dependencies
        end

        def build_dependencies_store(*args)
          DependenciesStore.new(*args).freeze
        end
      end

      def self.included(base)
        base.extend(BuilderModule)
        def base.inherited(children)
          children.dependencies dependencies
        end
      end

      attr_reader :resolved_dependencies

      def dependencies
        @dependencies ||= self.class.build_dependencies_store
      end

      # Override dependencies for a object
      #
      # @param  [Hash] dependencies
      # @return [DependenciesStore]
      # @raise  [ArgumentError] when a object has resolved dependencies
      def inject_dependencies(dependencies)
        raise ArgumentError, "Can't inject for a object with resolved dependencies" if dependencies_resolved?

        @dependencies = self.class.build_dependencies_store dependencies
      end

      # Resolve dependencies
      #
      # @return [Utils::Store]
      def resolve_dependencies
        raise StandardError, 'Dependencies already resolved' if dependencies_resolved?

        @resolved_dependencies = self.class.build_dependencies(dependencies)
      end

      # A state of dependencies
      #
      # @return [Boolean]
      def dependencies_resolved?
        !@resolved_dependencies.nil?
      end
    end
  end
end
