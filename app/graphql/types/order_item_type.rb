# frozen_string_literal: true

module Types
  class OrderItemType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :quantity, Integer, null: false
    field :price, Float, null: false
    field :total_price, Float, null: false
    field :customizations, GraphQL::Types::JSON, null: true
    field :menu_item_id, ID, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
