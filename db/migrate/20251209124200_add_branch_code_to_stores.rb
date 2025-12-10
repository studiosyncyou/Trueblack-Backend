class AddBranchCodeToStores < ActiveRecord::Migration[8.0]
  def change
    add_column :stores, :branch_code, :string
    add_index :stores, :branch_code
  end
end
