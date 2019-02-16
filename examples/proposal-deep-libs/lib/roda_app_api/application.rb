# frozen_string_literal: true

require 'qudo/application'
require 'qudo/container'
require_relative 'components/client'

module RodaAppApi
  class Application < Qudo::Application
    path Pathname.new(__dir__)

    config.resource = 'https://ghibliapi.herokuapp.com'

    containers.default = Qudo::Container.new
    containers.default.register :client, Components::Client, config
  end
end
