class AddAllergenInfoToMenuItems < ActiveRecord::Migration[8.0]
  def change
    add_column :menu_items, :allergen_info, :text
  end
end
