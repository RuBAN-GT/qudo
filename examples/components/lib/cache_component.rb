# frozen_string_literal: true

require 'bundle/setup'
require 'qudo/component'
require 'redis'

class CacheComponent < Qudo::Component
  config do
    attribute :host, Qudo::Types::Strict::String.default('0.0.0.0')
    attribute :port, Qudo::Types::Coercible::Integer.default(6379)
    attribute :db, Qudo::Types::Coercible::Integer.default(0)
  end

  builder do |config|
    Redis.new config
  end
end
