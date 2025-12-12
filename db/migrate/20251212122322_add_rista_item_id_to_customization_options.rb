class AddRistaItemIdToCustomizationOptions < ActiveRecord::Migration[8.0]
  def change
    add_column :customization_options, :rista_item_id, :string
  end
end
