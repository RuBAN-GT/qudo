# frozen_string_literal: true

require 'graphql'
require_relative './query_type'

module Api
  module Graphql
    class Schema < GraphQL::Schema
      query QueryType
    end
  end
end
