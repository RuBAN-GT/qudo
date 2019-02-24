# frozen_string_literal: true

require 'dry/inflector'
require_relative './file_loader'

module Qudo
  module Utils
    # The dynamic loader of classes from specific sources
    class ClassLoader
      # Specific inflector for generation class names and keys
      #
      # @return [Dry::Inflector]
      def self.default_inflector
        Dry::Inflector.new
      end

      attr_reader :inflector

      def initialize(inflector = nil)
        @inflector = inflector.nil? ? self.class.default_inflector : inflector
      end

      # Load list of classes located in specific files
      #
      # @example Load classes from components/cache/redis.rb
      #   ClassLoader.load_list(
      #     Pathname.new(__dir__).join('components', '**', '*.rb')
      #   ) #=> [Cache::Redis]
      #
      # @param  [Pathname,String] path with a specification (mask) about sources
      # @return [Array<Class>]
      def load_list(path)
        loaded = []
        FileLoader.recursive_file_handling(path) do |file|
          require file
          loaded << load_class(file, path)
          yield loaded.last if block_given?
        end

        loaded
      end

      # Load map (hash) with loaded classes and their underscored keys
      #
      # @example Load classes from components/cache/redis.rb
      #   ClassLoader.load_map(
      #     Pathname.new(__dir__).join('components', '**', '*.rb')
      #   ) #=> { cache_redis: Cache::Redis }
      #
      # @param  [Pathname,String] path with a specification (mask) about sources
      # @return [Hash<Symbol,Class>]
      def load_map(path)
        load_list(path).each_with_object({}) do |klass, hash|
          klass_key = generate_class_key klass
          hash[klass_key] = klass

          yield klass_key, klass if block_given?
        end
      end
      alias call load_map

      private

        def load_class(file, root)
          class_path = extract_pure_name(file, root)
          Object.const_get inflector.classify(class_path)
        end

        def extract_pure_name(file, root)
          basic_part = root.to_s.split('/*').first
          file.to_s.gsub(basic_part, '')[1...-3]
        end

        def generate_class_key(klass)
          klass_name = klass.name.gsub('::', '_')
          inflector.underscore(klass_name).to_sym
        end
    end
  end
end
