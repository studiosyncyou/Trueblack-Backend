class CreateMenuItemOptionSets < ActiveRecord::Migration[8.0]
  def change
    create_table :menu_item_option_sets do |t|
      t.references :menu_item, null: false, foreign_key: true
      t.references :option_set, null: false, foreign_key: true

      t.timestamps
    end
  end
end
