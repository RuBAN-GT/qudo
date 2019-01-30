# frozen_string_literal: true

require 'hashie'

module Qudo
  module Utils
    # The key-value register for any items
    class Register
      alias set register
      alias set! register!

      # Store with items
      #
      # @return [Hashie::Mash]
      def store
        @store ||= Hashie::Mash.new
      end

      # Get value from store
      #
      # @param  [String,Symbol] name
      # @return [*]
      def get(name)
        store[name]
      end

      # Strong getting of value from store
      #
      # @param  [String,Symbol] name
      # @return [*]
      # @raise  [StandardError] if key doesn't exists in store
      def get!(name)
        raise "#{name} doesn't exists in the store" unless exists? name

        get name
      end

      # Alias for getting of value by key
      #
      # @param  [String,Symbol] name
      # @return [*]
      def [](name)
        get name
      end

      # Sets value by key in store
      #
      # @param  [String,Symbol] name
      # @param  [*] name
      # @return [*]
      def register(name, item)
        casted_name = cast_name name
        manual_register casted_name, item if validate_registration(casted_name, item)
      end

      # Strong setting of value by key in store
      #
      # @param  [String,Symbol] name
      # @param  [*] name
      # @return [*]
      # @raise  [ArgumentError] on invalid result of validation
      def register!(name, item)
        casted_name = cast_name name
        validate_registration! casted_name, item
        manual_register casted_name, item
      end

      # Remove item from store
      #
      # @param  [String,Symbol] name
      # @return [*]
      def remove(name)
        store.delete name.to_sym
      end

      # Check item in store by name
      #
      # @param  [String,Symbol] name
      # @return [Boolean]
      def exists?(name)
        store.key? name.to_sym
      end

      private

        def cast_name(name)
          name.to_sym
        end

        def manual_register(name, item)
          store[name.to_sym] = item
        end

        def validate_registration(_name, _item)
          true
        end

        def validate_registration!(name, item)
          raise ArgumentError, "Can't add #{name} in store" unless validate_registration(name, item)
        end
    end
  end
end
