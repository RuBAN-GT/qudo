# frozen_string_literal: true

module Api
  module Graphql
    class QueryType < GraphQL::Schema::Object
      description 'The main field in my app'
      field :hello, String, null: false

      def hello
        'Hello world'
      end
    end
  end
end
