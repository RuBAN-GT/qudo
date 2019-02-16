# frozen_string_literal: true

require_relative './config'

module Qudo
  module Utils
    # A config generator over Hashie::Dash
    module ConfigBuilder
      # The config structure and schema validator
      #
      # @example
      #   class SomeClass
      #     extend Qudo::Utils::ConfigBuilder
      #
      #     config do
      #       property :host, required: true, default: '0.0.0.0'
      #       property :port, required: true, default: 3000
      #     end
      #   end
      #
      # @param  [Class<Hashie::Dash>, nil] configuration with existed class with structure
      # @param  [Proc] &block with body of structure
      # @return [Class<Hashie::Dash>]
      def config(configuration = nil, &block)
        return @config unless @config.nil?
        return @config = configuration unless configuration.nil?

        @config = default_config(&block) unless block.nil?
      end

      # The default configuration class without any scheme
      # @return [Class<Hashie::Dash>]
      def default_config(&block)
        Class.new(Config, &block)
      end

      # Build config instance
      # @param [Hashie::Dash, Hash]
      def build_config(options = {})
        config_class = config.nil? ? default_config : config
        config_class.new(options).freeze
      end
    end
  end
end
