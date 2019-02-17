# frozen_string_literal: true

require 'qudo/application'
require_relative 'components/client'

module RodaAppApi
  class Application < Qudo::Application
    path Pathname.new(__dir__)

    config.resource = 'https://ghibliapi.herokuapp.com'
    container.register :client, Components::Client, config

    def self.run
      boot!
      Router.freeze.app
    end
  end
end
