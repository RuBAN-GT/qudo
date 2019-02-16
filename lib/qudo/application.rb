# frozen_string_literal: true

require 'qudo/utils'
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

      def path(real_path = nil)
        return @path unless @path.nil?

        @path = Pathname.new(real_path) unless real_path.nil?
      end

      def boot
        require_internals
      end

      private

        def require_internals
          raise LoadError, 'Application has undefined #path' if path.nil?

          Utils.recursive_require path
        end
    end
  end
end
