# frozen_string_literal: true

require 'qudo/component'

module RodaAppApi
  module Components
    # Simple HTTP client for selected resource
    class Client < Qudo::Component
      config do |schema|
        schema.property :resource, required: true
      end

      def self.builder(config, *_)
        require 'rest-client'

        RestClient::Resource.new config.resource
      end
    end
  end
end
