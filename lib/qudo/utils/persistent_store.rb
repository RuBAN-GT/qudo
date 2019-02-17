# frozen_string_literal: true

require 'hashie'
require_relative './store'

module Qudo
  module Utils
    # Hash wrapper that allowing to set values only once
    class PersistentStore < Store
      include Hashie::Extensions::Mash::SafeAssignment

      def regular_writer(key, *args)
        raise ArgumentError, "#{key} already exists" if key? key

        super key, *args
      end
    end
  end
end
