class CreateComments < ActiveRecord::Migration[8.1]
  def change
    create_table :comments do |t|
      t.references :user, null: false, foreign_key: true
      t.references :commentable, polymorphic: true, null: false
      t.references :parent, foreign_key: { to_table: :comments }
      t.text :body, null: false

      t.timestamps

      t.index [:commentable_type, :commentable_id]
      t.index [:parent_id, :created_at]
    end
  end
end
