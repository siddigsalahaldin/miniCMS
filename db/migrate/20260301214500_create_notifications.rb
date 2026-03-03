class CreateNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.references :actor, null: true, foreign_key: { to_table: :users }
      t.string :notifiable_type, null: false
      t.integer :notifiable_id, null: false
      t.string :notification_type, null: false
      t.boolean :read, default: false, null: false
      t.text :params

      t.timestamps

      t.index [:user_id, :read]
      t.index [:notifiable_type, :notifiable_id]
    end
  end
end
