class CreateCustomizationOptions < ActiveRecord::Migration[8.0]
  def change
    create_table :customization_options do |t|
      t.references :option_set, null: false, foreign_key: true
      t.string :name
      t.decimal :price
      t.string :rista_option_id
      t.boolean :is_default

      t.timestamps
    end
  end
end
