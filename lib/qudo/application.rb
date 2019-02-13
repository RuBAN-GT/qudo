# frozen_string_literal: true

require 'qudo/utils/persistent_store'

module Qudo
  # A representation of a application with containers and unique config
  class Application
    class << self
      def config
        @config ||= Utils::PersistentStore.new
      end

      def container
        containers[:default]
      end

      def containers
        @containers ||= Utils::PersistentStore.new
      end
    end
  end
end
