# frozen_string_literal: true

module Qudo
  # Collection of different independent functions
  module Utils
    class << self
      def recursive_file_handling(mask, &block)
        Dir[mask].each(&block)
      end

      # Require rb-files by path
      #
      # @param [String,Pathname] path
      # @param [String] mask
      def recursive_require(path, mask = '/**/*.rb')
        recursive_file_handling(path.to_s + mask) { |f| require f }
      end
    end
  end
end
