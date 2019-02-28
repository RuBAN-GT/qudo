# frozen_string_literal: true

require 'qudo/application'

module Api
  class Application < Qudo::Application
    path Pathname.new(__dir__)

    def self.run
      boot!
      Router.freeze.app
    end
  end
end
