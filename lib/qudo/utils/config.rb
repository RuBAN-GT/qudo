# frozen_string_literal: true

require 'hashie'

module Qudo
  module Utils
    # Symbolized version of Hashie::Dash
    class Config < Hashie::Dash
      include Hashie::Extensions::IgnoreUndeclared

      def self.property(name, *args)
        super name.to_sym, *args
      end

      def self.property?(name)
        super name.to_sym
      end

      def initialize(attributes = {}, &block)
        attributes = attributes.to_h if attributes.respond_to? :to_h
        attributes = Hashie::Extensions::SymbolizeKeys.symbolize_keys attributes

        super(attributes, &block)
      end

      def []=(property, value)
        super property.to_sym, value
      end

      def [](property)
        super property.to_sym
      end
    end
  end
end
