namespace :menu do
  desc "Remove duplicate menu items (keep only Rista-synced items)"
  task cleanup_duplicates: :environment do
    puts "=== Cleaning up duplicate menu items ==="

    # Count items before cleanup
    total_items = MenuItem.count
    items_without_rista_code = MenuItem.where(rista_code: nil).count
    items_with_rista_code = MenuItem.where.not(rista_code: nil).count

    puts "\nBefore cleanup:"
    puts "  Total items: #{total_items}"
    puts "  Items WITHOUT rista_code (old local data): #{items_without_rista_code}"
    puts "  Items WITH rista_code (Rista synced): #{items_with_rista_code}"

    # Delete all items without rista_code
    puts "\n🗑️  Deleting items without rista_code..."
    deleted_count = MenuItem.where(rista_code: nil).delete_all

    puts "✅ Deleted #{deleted_count} items"

    # Show final counts
    remaining_items = MenuItem.count
    puts "\nAfter cleanup:"
    puts "  Remaining items: #{remaining_items}"

    # Check for any remaining duplicates by name
    duplicate_names = MenuItem.select(:name)
                             .group(:name)
                             .having('COUNT(*) > 1')
                             .count

    if duplicate_names.any?
      puts "\n⚠️  Warning: Still have #{duplicate_names.length} duplicate names:"
      duplicate_names.each do |name, count|
        puts "    - '#{name}' appears #{count} times"
      end
    else
      puts "\n✅ No duplicate names found!"
    end
  end
end
