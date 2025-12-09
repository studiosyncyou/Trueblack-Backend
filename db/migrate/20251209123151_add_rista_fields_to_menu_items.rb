class AddRistaFieldsToMenuItems < ActiveRecord::Migration[8.0]
  def change
    # Add Rista metadata for menu sync
    add_column :menu_items, :rista_code, :string
    add_column :menu_items, :rista_category_id, :string
    add_column :menu_items, :rista_subcategory_id, :string
    add_column :menu_items, :short_name, :string
    # is_available already exists, skip it
    add_column :menu_items, :last_synced_at, :datetime

    # Add index on rista_code for faster lookups during sync
    add_index :menu_items, :rista_code, unique: true
  end
end
