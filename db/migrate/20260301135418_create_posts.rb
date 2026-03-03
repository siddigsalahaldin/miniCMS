class CreatePosts < ActiveRecord::Migration[8.1]
  def change
    create_table :posts do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.string :slug, null: false
      t.boolean :published, default: false, null: false

      t.timestamps

      t.index :slug, unique: true
      t.index [:user_id, :created_at]
    end
  end
end
