# frozen_string_literal: true

module Api
  module V1
    class AdminController < ApplicationController
      skip_before_action :authenticate_user!

      # GET /api/v1/admin/fix-data
      def fix_data
        results = {
          stores_updated: 0,
          orders_updated: 0,
          errors: []
        }

        begin
          # Fix stores with null branch_code
          stores_count = Store.where(branch_code: nil).update_all(branch_code: 'KKT')
          results[:stores_updated] = stores_count

          # Fix orders with null total_amount
          Order.where(total_amount: nil).find_each do |order|
            total = order.order_items.sum { |item| item.total_price || (item.price * item.quantity) }
            order.update_column(:total_amount, total || 0)
            results[:orders_updated] += 1
          end

          render json: {
            success: true,
            message: "✅ Data fixed successfully!",
            results: results
          }, status: :ok

        rescue StandardError => e
          results[:errors] << e.message
          render json: {
            success: false,
            message: "❌ Error fixing data",
            results: results,
            error: e.message
          }, status: :internal_server_error
        end
      end
    end
  end
end
