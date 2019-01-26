# frozen_string_literal: true

require 'dry-struct'

module Qudo
  module Utils
    # Simple config generator over dry-struct
    module ConfigBuilder
      # The config structure and schema validator
      #
      # @example
      #   class SomeClass
      #     extend Qudo::Utils::ConfigBuilder
      #
      #     config do
      #       attribute :host, Types::Strict::String.default('0.0.0.0')
      #       attribute :port, Types::Coercible::Integer.default(6379)
      #     end
      #   end
      #
      # @param  [Class<Dry::Struct>, nil] configuration with existed class with structure
      # @param  [Proc] &block with body of structure
      # @return [Class<Dry::Struct>]
      def config(configuration = nil, &block)
        return @config unless @config.nil?
        return @config = configuration unless configuration.nil?

        @config = default_config(&block) unless block.nil?
      end

      # The default configuration class without any scheme
      # @return [Class<Dry::Struct>]
      def default_config(&block)
        Class.new Dry::Struct, &block
      end

      # Build config instance
      # @param [Dry::Struct, Hash]
      def build_config(options = {})
        config_class = config.nil? ? default_config : config
        config_class.new options
      end
    end
  end
end
