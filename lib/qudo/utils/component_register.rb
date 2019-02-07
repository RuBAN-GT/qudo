# frozen_string_literal: true

require 'dry/inflector'
require 'qudo/utils/register'
require 'qudo/component'

module Qudo
  module Utils
    # Customized Register for components
    #
    # @see [Qudo::Utils::Register]
    # @see [Qudo::Component]
    class ComponentRegister < Register
      def self.inflector
        @inflector ||= Dry::Inflector.new
      end

      def compatible?(component)
        component.is_a? Qudo::Component
      end

      private

        def cast_name(name)
          self.class.inflector.foreign_key name.to_s.gsub(%r{/[\/:]+/}, '_')
        end
    end
  end
end
