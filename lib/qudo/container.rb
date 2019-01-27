# frozen_string_literal: true

require 'dry/inflector'
require 'qudo/utils/component_register'

module Qudo
  # The wrapper for working with components
  class Container
    def components
      @components = Utils::ComponentRegister.new
    end
  end
end
