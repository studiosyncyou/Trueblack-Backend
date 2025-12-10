module Api
  module V1
    class OrdersController < ApplicationController
      before_action :authenticate_user!

      # POST /api/v1/orders
      # Creates order in our DB and proxies to Rista
      def create
        @order = nil

        ActiveRecord::Base.transaction do
          # 1. Create order in our database
          @order = current_user.orders.create!(
            store_id: order_params[:storeId] || order_params[:store_id],
            branch_code: order_params[:branchCode] || order_params[:branch_code],
            order_type: order_params[:orderType] || order_params[:order_type] || 'pickup',
            payment_method: order_params[:paymentMethod] || order_params[:payment_method] || 'cash',
            customer_phone: current_user.phone,
            customer_name: current_user.name,
            total_amount: order_params[:totalAmount] || order_params[:total_amount] || 0,
            notes: order_params[:notes],
            table_number: order_params[:tableNumber] || order_params[:table_number],
            status: 'pending'
          )

          # 2. Create order items
          items_data = order_params[:items] || []
          items_data.each do |item|
            # Find menu item by ID or rista_code
            menu_item = find_menu_item(item)

            next unless menu_item

            @order.order_items.create!(
              menu_item: menu_item,
              quantity: item[:quantity] || 1,
              price: item[:price] || menu_item.price
            )
          end

          # Recalculate total if not provided
          if @order.total_amount.zero?
            @order.update!(total_amount: @order.calculate_total)
          end
        end
        puts ENV['RISTA_API_KEY']
         Rails.logger.info "Order creation failed: #{ENV['RISTA_API_KEY']}"
        # 3. Proxy to Rista API (outside transaction)
        proxy_to_rista(@order)

        # 4. Return response
        render json: transform_order_response(@order), status: :created

      rescue ActiveRecord::RecordInvalid => e
        render json: { error: e.message, details: e.record&.errors&.full_messages }, status: :unprocessable_entity
      rescue => e
        Rails.logger.error "Order creation failed: #{e.message}"
        render json: { error: 'Order creation failed', message: e.message }, status: :unprocessable_entity
      end

      # GET /api/v1/orders (user's order history)
      def index
        @orders = current_user.orders
          .includes(order_items: :menu_item)
          .recent
          .limit(50)

        render json: @orders.map { |order| transform_order_response(order) }
      end

      # GET /api/v1/orders/:id
      def show
        @order = current_user.orders.find(params[:id])
        render json: transform_order_response(@order)
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Order not found' }, status: :not_found
      end

      private

      def order_params
        params.permit(
          :storeId, :store_id, :branchCode, :branch_code,
          :orderType, :order_type, :paymentMethod, :payment_method,
          :totalAmount, :total_amount, :notes, :tableNumber, :table_number,
          items: [:id, :menu_item_id, :name, :quantity, :price, :ristaData => [:code, :itemId]],
          customer: [:phone, :name]
        )
      end

      def find_menu_item(item_data)
        # Try to find by menu_item_id first
        return MenuItem.find_by(id: item_data[:menu_item_id] || item_data[:id]) if item_data[:menu_item_id] || item_data[:id]

        # Try to find by rista_code
        rista_code = item_data.dig(:ristaData, :code) || item_data.dig(:rista_data, :code)
        return MenuItem.find_by(rista_code: rista_code) if rista_code

        nil
      end

      def proxy_to_rista(order)
        return unless order.branch_code.present?

        begin
          rista_api = RistaApiService.new
          rista_sale_data = transform_order_to_rista_sale(order)

          Rails.logger.info "[Orders] Proxying order #{order.id} to Rista"

          response = rista_api.create_sale(rista_sale_data)

          # Update order with Rista invoice
          order.update!(
            rista_invoice_number: response['invoice'] || response['invoiceNumber'],
            status: 'confirmed'
          )

          Rails.logger.info "[Orders] Rista order created: #{order.rista_invoice_number}"

        rescue RistaApiService::RistaApiError => e
          Rails.logger.error "[Orders] Rista API error for order #{order.id}: #{e.message}"
          # Order still exists in our DB, just no Rista invoice
          # Don't fail the entire order creation
        rescue => e
          Rails.logger.error "[Orders] Unexpected error proxying to Rista: #{e.message}"
        end
      end

      def transform_order_to_rista_sale(order)
        {
          branchCode: order.branch_code,
          channel: 'Dine In', # TODO: Map order_type to channel
          customer: {
            phoneNumber: order.customer_phone,
            name: order.customer_name
          },
          items: order.order_items.map { |item|
            {
              code: item.menu_item.rista_code || item.menu_item.id.to_s,
              name: item.menu_item.name,
              shortName: item.menu_item.short_name || item.menu_item.name,
              quantity: item.quantity,
              unitPrice: item.price
            }
          },
          payments: [{
            mode: order.payment_method,
            amount: order.total_amount
          }],
          notes: order.notes || ''
        }
      end

      def transform_order_response(order)
        {
          id: order.id,
          invoiceNumber: order.rista_invoice_number,
          status: order.status,
          orderType: order.order_type,
          paymentMethod: order.payment_method,
          totalAmount: order.total_amount.to_f,
          notes: order.notes,
          tableNumber: order.table_number,
          customer: {
            phone: order.customer_phone,
            name: order.customer_name
          },
          items: order.order_items.map { |item|
            {
              id: item.menu_item.id,
              name: item.menu_item.name,
              quantity: item.quantity,
              price: item.price.to_f,
              totalPrice: (item.price * item.quantity).to_f
            }
          },
          createdAt: order.created_at.iso8601,
          updatedAt: order.updated_at.iso8601,
          ristaData: {
            invoice: order.rista_invoice_number,
            synced: order.rista_synced?
          }
        }
      end
    end
  end
end
