# frozen_string_literal: true

namespace :db do
  desc "Fix orders with null total_amount"
  task fix_orders: :environment do
    puts "Finding orders with null total_amount..."

    orders = Order.where(total_amount: nil)
    puts "Found #{orders.count} orders with null total_amount"

    orders.each do |order|
      # Calculate total from order items
      total = order.order_items.sum { |item| item.total_price || (item.price * item.quantity) }

      if total > 0
        order.update!(total_amount: total)
        puts "✓ Fixed Order ##{order.id}: set total_amount = #{total}"
      else
        puts "✗ Order ##{order.id}: Cannot calculate total (no items or zero total)"
      end
    end

    puts "\nDone!"
  end
end
