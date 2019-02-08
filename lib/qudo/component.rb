# frozen_string_literal: true

require 'qudo/dependencies/dependencies_builder'
require 'qudo/object_factory'
require 'qudo/utils/config_builder'

module Qudo
  # Basic class for components
  class Component < ObjectFactory
    include Dependencies::DependenciesBuilder
    extend Utils::ConfigBuilder

    attr_reader :config

    # @param options [Hash]
    def initialize(options = {})
      @config = self.class.build_config options
      inject_dependencies options[:dependencies] if options.key? :dependencies
    end

    def build_args
      @build_args ||= [config, resolve_dependencies]
    end
  end
end
