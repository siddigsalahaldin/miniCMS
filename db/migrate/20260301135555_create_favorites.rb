class CreateFavorites < ActiveRecord::Migration[8.1]
  def change
    create_table :favorites do |t|
      t.references :user, null: false, foreign_key: true
      t.references :post, null: false, foreign_key: true

      t.timestamps

      t.index [:user_id, :post_id], unique: true, name: "index_favorites_on_user_and_post"
      t.index [:post_id, :created_at]
    end
  end
end
