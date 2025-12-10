# frozen_string_literal: true

module Types
  class OrderType < Types::BaseObject
    field :id, ID, null: false
    field :user_id, ID, null: true
    field :store_id, ID, null: true
    field :branch_code, String, null: true
    field :status, String, null: false
    field :total_amount, Float, null: true, description: "Total order amount (computed from items if null)"
    field :payment_method, String, null: true
    field :order_type, String, null: true
    field :notes, String, null: true

    # Rista integration fields
    field :rista_invoice_number, String, null: true, description: "Invoice number from Rista POS (null if not synced)"
    field :rista_synced, Boolean, null: false, description: "Whether order was successfully synced to Rista POS"

    # Order items
    field :order_items, [Types::OrderItemType], null: false

    # Timestamps
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    # Computed field to check if synced to Rista
    def rista_synced
      object.rista_invoice_number.present?
    end
  end
end
