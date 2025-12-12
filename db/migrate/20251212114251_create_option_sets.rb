class CreateOptionSets < ActiveRecord::Migration[8.0]
  def change
    create_table :option_sets do |t|
      t.string :name
      t.string :rista_option_set_id

      t.timestamps
    end
  end
end
