# frozen_string_literal: true

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
  #     def self.builder(opts)
  #       require 'redis'
  #       Redis.new opts.config
  #     end
  #   end
  #
  # @attr_reader [Config] config with instance of a component configuration
  class Component < ObjectFactory
    extend Utils::ConfigBuilder

    attr_reader :config

    # @param [Hash] options
    def initialize(options = {})
      @config = self.class.build_config options
    end

    private

      def generate_builder_opts
        super.tap { |store| store.config = config }
      end
  end
end
