class AddMissingFieldsToOptionSets < ActiveRecord::Migration[8.0]
  def change
    add_column :option_sets, :display_name, :string
    add_column :option_sets, :min_selections, :integer
    add_column :option_sets, :max_selections, :integer
  end
end
