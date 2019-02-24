# frozen_string_literal: true

module Qudo
  module Utils
    # A secondary attributes definition
    #
    # @example
    #   class MyClass
    #     include Qudo::Utils::Properties
    #
    #     property :my_prop, 42
    #
    #     def my_prop
    #       properties[:my_prop]
    #     end
    #   end
    #
    #   instance = MyClass.new
    #   instance.my_prop #=> 42
    module Properties
      # Class-level properties
      module ClassProperties
        # Get an original object with class properties
        #
        # @return [Hash]
        def properties
          @properties ||= {}
        end

        # Set or get property
        #
        # @example set a property
        #   property :scalar_prop, 42 #=> 42
        #   property :proc_prop, { 42 } #=> Proc, will be resolved on getting request
        #
        # @example get a selected property
        #   property :some_prop #=> returns property value
        #
        # @param  [Symbol,String] name
        # @param  [*] value with a property value
        # @return [*] with value
        def property(name, *args)
          return resolve_property(name) if args.empty?

          register_property name, args.first
        end

        private

          def resolve_property(name)
            prop_key = name.to_sym
            prop_val = properties[prop_key]

            prop_val.is_a?(Proc) ? (properties[prop_key] = prop_val.call) : prop_val
          end

          def register_property(name, value)
            properties[name.to_sym] = value
          end
      end

      def self.included(base)
        base.extend ClassProperties
      end

      # Get freeze properties for instance usage
      #
      # @return [Hash]
      def properties
        @properties ||= self.class.properties.dup.freeze
      end
    end
  end
end
