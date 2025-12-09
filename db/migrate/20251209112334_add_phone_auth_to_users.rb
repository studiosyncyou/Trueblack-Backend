class AddPhoneAuthToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :phone, :string
    add_index :users, :phone, unique: true
    add_column :users, :name, :string

    # Make password optional for phone auth
    change_column_null :users, :password_digest, true
  end
end
