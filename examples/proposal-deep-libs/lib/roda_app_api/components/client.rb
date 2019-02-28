# frozen_string_literal: true

require 'qudo/component'

module RodaAppApi
  module Components
    # Simple HTTP client for selected resource
    class Client < Qudo::Component
      config do |schema|
        schema.property :resource, required: true
      end

      def self.builder(opts)
        require 'rest-client'

        RestClient::Resource.new opts.config.resource
      end
    end
  end
end
