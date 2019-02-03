# frozen_string_literal: true

require_relative './dependence_resolver'

module Qudo
  module Utils
    # Extendable module for dependencies declaration and building
    module DependenciesBuilder
      # Dependencies declaration
      #
      # @param  [Array<String,Symbol>] dependencies
      # @return [Array<String,Symbol>]
      def dependencies(dependencies = [])
        return @dependencies unless dependencies.nil?

        @dependencies = dependencies
      end

      # Build dependencies from injectable argument
      #
      # @param  [Hash, Register] manager
      # @return [Hashie::Mash]
      def build_dependencies(manager)
        DependenceResolver.resolve manager, dependencies
      end
    end
  end
end
