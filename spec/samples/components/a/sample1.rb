# frozen_string_literal: true

require 'qudo/component'

module A
  class Sample1 < Qudo::Component
    builder { 42 }
  end
end
