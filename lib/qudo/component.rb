# frozen_string_literal: true

require_relative 'object_factory'
require_relative 'types'
require_relative 'utils/config_builder'

module Qudo
  # Basic class for components
  class Component < ObjectFactory
    extend Utils::ConfigBuilder

    attr_reader :config

    # @param options [Hash]
    def initialize(options = {})
      @config = self.class.build_config options
    end

    def build_args
      @build_args ||= [config]
    end
  end
end
