class CreateFollows < ActiveRecord::Migration[8.1]
  def change
    create_table :follows do |t|
      t.references :follower, null: false, foreign_key: { to_table: :users }
      t.references :followed, null: false, foreign_key: { to_table: :users }

      t.timestamps

      t.index [:follower_id, :followed_id], unique: true
    end

    add_check_constraint :follows, "follower_id != followed_id", name: "follower_not_followed_self"
  end
end
