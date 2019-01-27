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

      private

        def cast_name(name)
          self.class.inflector.foreign_key name.to_s.gsub(%r{/[\/:]+/}, '_')
        end

        def validate_registration(_name, component)
          component.is_a? Qudo::Component
        end
    end
  end
end
