class AddBranchCodeToStores < ActiveRecord::Migration[8.0]
  def change
    add_column :stores, :branch_code, :string unless column_exists?(:stores, :branch_code)
    add_index :stores, :branch_code unless index_exists?(:stores, :branch_code)
  end
end
