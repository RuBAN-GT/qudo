# frozen_string_literal: true

require 'qudo/dependencies/dependencies_builder'
require 'qudo/object_factory'
require 'qudo/types'
require 'qudo/utils/config_builder'

module Qudo
  # Basic class for components
  class Component < ObjectFactory
    extend Dependencies::DependenciesBuilder
    extend Utils::ConfigBuilder

    attr_reader :config, :dependencies

    # @param options [Hash]
    def initialize(options = {})
      @config       = self.class.build_config options
      @dependencies = options.fetch :dependencies, {}
    end

    def build_args
      @build_args ||= [config, resolved_dependencies]
    end

    def resolved_dependencies
      @resolved_dependencies ||= self.class.build_dependencies(dependencies)
    end
  end
end
