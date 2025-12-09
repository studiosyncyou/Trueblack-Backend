class CreateMenuSyncLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :menu_sync_logs do |t|
      t.string :status  # running, success, failed
      t.integer :items_synced
      t.text :error_message
      t.datetime :started_at
      t.datetime :completed_at

      t.timestamps
    end

    add_index :menu_sync_logs, :status
    add_index :menu_sync_logs, :completed_at
  end
end
