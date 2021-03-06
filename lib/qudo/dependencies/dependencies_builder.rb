# frozen_string_literal: true

require 'hashie'
require_relative './dependencies_resolver'

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
        def dependencies(dependencies = [])
          return @dependencies unless @dependencies.nil?

          @dependencies = dependencies
        end

        # Build dependencies from injectable argument
        #
        # @param  [Hash] manager
        # @return [Hashie::Mash]
        def build_dependencies(manager)
          DependenciesResolver.resolve manager, dependencies
        end
      end

      def self.included(base)
        base.extend(BuilderModule)
      end

      attr_reader :resolved_dependencies

      def dependencies
        @dependencies ||= Hashie::Mash.new
      end

      # Override dependencies for a object
      #
      # @param  [Hash] dependencies
      # @return [Hashie::Mash]
      # @raise  [ArgumentError] when a object has resolved dependencies
      def inject_dependencies(dependencies)
        raise ArgumentError, "Can't inject for resolved dependencies" if dependencies_resolved?

        @dependencies = Hashie::Mash.new dependencies
      end

      # Resolve dependencies
      #
      # @return [Hashie::Mash]
      def resolve_dependencies
        raise StandardError, 'Dependencies already resolved' if dependencies_resolved?

        @resolved_dependencies = self.class.build_dependencies(dependencies)
      end

      # The state of dependencies
      #
      # @return [Boolean]
      def dependencies_resolved?
        !@resolved_dependencies.nil?
      end
    end
  end
end
