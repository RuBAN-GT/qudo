# frozen_string_literal: true

require 'json'
require 'roda'

module RodaAppApi
  # @see https://roda.jeremyevans.net/
  class Router < Roda
    plugin :json

    route do |r|
      r.root { 'Hello world!' }

      r.get 'films' do
        JSON.parse Application.container[:client].resolve['/films'].get
      end
    end
  end
end
