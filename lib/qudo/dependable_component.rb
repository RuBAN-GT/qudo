# frozen_string_literal: true

require 'qudo/component'
require 'qudo/dependencies/dependencies_builder'

module Qudo
  module Dependencies
    # Component that supports for dependencies
    class DependableComponent < Component
      include Dependencies::DependenciesBuilder

      def initialize(options = {})
        super(options)

        inject_dependencies options[:dependencies] if options.key? :dependencies
      end

      private

        def generate_builder_opts
          super.tap { |store| store.dependencies = resolve_dependencies }
        end
    end
  end
end
