class EnhanceOrdersForUserTracking < ActiveRecord::Migration[8.0]
  def change
    # Add user tracking
    add_reference :orders, :user, foreign_key: true, index: true

    # Add store and Rista branch tracking
    add_column :orders, :store_id, :bigint
    add_column :orders, :branch_code, :string

    # Add order details
    add_column :orders, :order_type, :string  # pickup, dine-in, delivery
    add_column :orders, :payment_method, :string
    add_column :orders, :customer_phone, :string
    add_column :orders, :customer_name, :string

    # Add Rista integration fields
    add_column :orders, :rista_invoice_number, :string
    add_column :orders, :total_amount, :decimal, precision: 10, scale: 2
    add_column :orders, :notes, :text

    # Update status to include more states
    # status: pending, confirmed, preparing, ready, completed, cancelled
    change_column_default :orders, :status, 'pending'

    # Make table_number nullable (only required for dine-in)
    change_column_null :orders, :table_number, true
  end
end
