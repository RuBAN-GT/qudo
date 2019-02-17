# frozen_string_literal: true

require 'qudo/utils'
require 'qudo/utils/persistent_store'

module Qudo
  # A representation of a application with containers and unique config
  class Application
    class << self
      def booted?
        @booted ||= false
      end

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
        boot_workflow unless booted?
      end

      def boot!
        raise LoadError, 'Application is already booted' if booted?

        boot_workflow
      end

      private

        def boot_workflow
          require_internals
          finalize_booting
        end

        def require_internals
          raise LoadError, 'Application has undefined #path' if path.nil?

          Utils.recursive_require path
        end

        def finalize_booting
          @booted = true
        end
    end
  end
end
