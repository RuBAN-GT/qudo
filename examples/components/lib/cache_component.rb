# frozen_string_literal: true

require 'bundle/setup'
require 'qudo/component'
require 'redis'

class CacheComponent < Qudo::Component
  config do |schema|
    schema.property :host, required: true, default: '0.0.0.0'
    schema.property :port, required: true, default: 6379
    schema.property :db,   required: true, default: 0
  end

  builder do |config|
    Redis.new config
  end
end
