# frozen_string_literal: true

require 'qudo/component'

module A
  module B
    class Sample2 < Qudo::Component
      builder { 42 }
    end
  end
end
