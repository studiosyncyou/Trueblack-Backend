class AddDietaryTypeToMenuItems < ActiveRecord::Migration[8.0]
  def change
    add_column :menu_items, :dietary_type, :string
  end
end
