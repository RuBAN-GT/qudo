# frozen_string_literal: true

require 'json'
require 'roda'

module Api
  class Router < Roda
    plugin :json

    route do |r|
      r.root { 'Graphql API' }

      r.post 'graphql' do
        input = JSON.parse request.body.read
        result = Graphql::Schema.execute input['query'],
                                         context: {},
                                         operation_name: input['operationName'],
                                         variables: input['variables']
        result.to_h.to_json
      end
    end
  end
end
