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

      # GET /api/v1/admin/debug-env
      def debug_env
        render json: {
          rista_api_key_set: ENV['RISTA_API_KEY'].present?,
          rista_secret_set: ENV['RISTA_SECRET'].present?,
          rista_base_url_set: ENV['RISTA_API_BASE_URL'].present?,
          rista_default_branch: ENV['RISTA_DEFAULT_BRANCH'],
          rails_env: Rails.env,
          all_rista_vars: ENV.select { |k, _| k.start_with?('RISTA') }.keys
        }
      end

      # GET /api/v1/admin/test-rista
      def test_rista
        begin
          rista_api = RistaApiService.new

          # Check if config is valid
          config_valid = rista_api.validate_config

          # Try to get catalog
          catalog = rista_api.get_catalog('KKT', 'Dine In')

          render json: {
            success: true,
            message: "✅ Rista API working!",
            config_valid: config_valid,
            catalog_items_count: catalog.dig('items')&.length || 0,
            sample_item: catalog.dig('items')&.first
          }, status: :ok

        rescue RistaApiService::RistaApiError => e
          render json: {
            success: false,
            error_type: "RistaApiError",
            message: e.message,
            hint: "Check RISTA_API_KEY, RISTA_SECRET, and RISTA_API_BASE_URL environment variables"
          }, status: :bad_gateway

        rescue StandardError => e
          render json: {
            success: false,
            error_type: e.class.name,
            message: e.message,
            backtrace: e.backtrace.first(5)
          }, status: :internal_server_error
        end
      end
    end
  end
end
