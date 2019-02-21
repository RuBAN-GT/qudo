# frozen_string_literal: true

module Qudo
  module Utils
    # The util can help to load and handle file by patterns
    module FileLoader
      class << self
        def recursive_file_handling(mask, &block)
          Dir[mask].each(&block)
        end

        # Require rb-files by path
        #
        # @param [String,Pathname] path
        # @param [String] mask
        def recursive_require(path, mask = '/**/*.rb')
          recursive_file_handling(path.to_s + mask) do |file|
            require file
            yield   file if block_given?
          end
        end
      end
    end
  end
end
