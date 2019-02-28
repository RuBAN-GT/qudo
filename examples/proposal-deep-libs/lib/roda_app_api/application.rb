# frozen_string_literal: true

require 'qudo/application'

module RodaAppApi
  class Application < Qudo::Application
    path Pathname.new(__dir__)

    config.resource = 'https://ghibliapi.herokuapp.com'
    container.auto_register path.join('components', '**/*.rb'), config

    def self.run
      boot!
      Router.freeze.app
    end
  end
end
