# frozen_string_literal: true

require 'qudo/dependencies/dependencies_builder'
require 'qudo/object_factory'
require 'qudo/utils/config_builder'

module Qudo
  # A factory of components definition
  #
  # @example Redis component
  #   class CacheComponent < Qudo::Component
  #     config do |schema|
  #       schema.property :host, required: true, default: '0.0.0.0'
  #       schema.property :port, required: true, default: 6379
  #       schema.property :db,   required: true, default: 0
  #     end
  #
  #     def self.builder(config, *_)
  #       require 'redis'
  #       Redis.new config
  #     end
  #   end
  #
  # @attr_reader [Config] config with instance of a component configuration
  class Component < ObjectFactory
    include Dependencies::DependenciesBuilder
    extend Utils::ConfigBuilder

    attr_reader :config

    # @param [Hash] options
    def initialize(options = {})
      @config = self.class.build_config options
      inject_dependencies options[:dependencies] if options.key? :dependencies
    end

    def build_args
      @build_args ||= [config, resolve_dependencies]
    end
  end
end
