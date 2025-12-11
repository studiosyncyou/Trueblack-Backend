# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    field :node, Types::NodeType, null: true, description: "Fetches an object given its ID." do
      argument :id, ID, required: true, description: "ID of the object."
    end

    def node(id:)
      context.schema.object_from_id(id, context)
    end

    field :nodes, [ Types::NodeType, null: true ], null: true, description: "Fetches a list of objects given a list of IDs." do
      argument :ids, [ ID ], required: true, description: "IDs of the objects."
    end

    def nodes(ids:)
      ids.map { |id| context.schema.object_from_id(id, context) }
    end

    # Add root-level fields here.
    # They will be entry points for queries on your schema.

    # TODO: remove me
    field :test_field, String, null: false,
      description: "An example field added by the generator"
    def test_field
      "Hello World!"
    end
    field :stores, [ Types::StoreType ], null: false,
      description: "Returns a list of all stores"
    def stores
      Store.all.includes(categories: :menu_items)
    end

    field :orders, [ Types::OrderType ], null: false,
      description: "Returns a list of all orders" do
      argument :user_id, ID, required: false, description: "Filter by user ID"
      argument :status, String, required: false, description: "Filter by order status"
      argument :limit, Integer, required: false, description: "Limit number of results"
    end
    def orders(user_id: nil, status: nil, limit: nil)
      orders = Order.includes(:order_items).order(created_at: :desc)
      orders = orders.where(user_id: user_id) if user_id
      orders = orders.where(status: status) if status
      orders = orders.limit(limit) if limit
      orders
    end

    field :order, Types::OrderType, null: true,
      description: "Returns a single order by ID" do
      argument :id, ID, required: true, description: "Order ID"
    end
    def order(id:)
      Order.includes(:order_items).find_by(id: id)
    end

    field :debug_env, GraphQL::Types::JSON, null: false,
      description: "Debug environment variables"
    def debug_env
      {
        rista_api_key_set: ENV['RISTA_API_KEY'].present?,
        rista_secret_set: ENV['RISTA_SECRET'].present?,
        rista_base_url_set: ENV['RISTA_API_BASE_URL'].present?,
        rista_default_branch: ENV['RISTA_DEFAULT_BRANCH'],
        rails_env: Rails.env.to_s,
        all_rista_vars: ENV.select { |k, _| k.start_with?('RISTA') }.keys
      }
    end
  end
end
