# frozen_string_literal: true

require 'qudo/container'
require 'qudo/utils/file_loader'
require 'qudo/utils/persistent_store'

module Qudo
  # A representation of a application with containers and unique config
  class Application
    DEFAULT_CONTAINER = :master

    class << self
      def booted?
        @booted ||= false
      end

      def config
        @config ||= Utils::PersistentStore.new
      end

      def container
        containers[DEFAULT_CONTAINER]
      end

      def containers
        @containers ||= Utils::PersistentStore.new.tap do |container_store|
          container_store[DEFAULT_CONTAINER] = build_default_container
        end
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

        def build_default_container
          Container.new
        end

        def boot_workflow
          require_internals
          finalize_booting
        end

        def require_internals
          raise LoadError, 'Application has undefined #path' if path.nil?

          Utils::FileLoader.recursive_require path
        end

        def finalize_booting
          @booted = true
        end
    end
  end
end
