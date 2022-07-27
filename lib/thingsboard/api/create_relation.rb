# frozen_string_literal: true

module Thingsboard
  module Api
    class CreateRelation < Base
      receives :token

      receives :from_id
      receives :from_entity_type
      receives :to_id
      receives :to_entity_type
      receives :relation_type

      protected

      def api_endpoint
        'api/relation'
      end

      def request_body
        {
          from: {
            'id'         => from_id,
            'entityType' => from_entity_type
          },
          to:   {
            'id'         => to_id,
            'entityType' => to_entity_type
          },
          type: relation_type
        }.to_json
      end
    end
  end
end
