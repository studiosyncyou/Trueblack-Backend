class CreateOtpSessions < ActiveRecord::Migration[8.0]
  def change
    create_table :otp_sessions do |t|
      t.string :phone, null: false
      t.string :otp, null: false
      t.string :session_id, null: false
      t.datetime :expires_at, null: false
      t.boolean :verified, default: false

      t.timestamps
    end
    add_index :otp_sessions, :session_id, unique: true
    add_index :otp_sessions, :phone
  end
end
