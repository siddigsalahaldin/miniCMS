class CreateReactions < ActiveRecord::Migration[8.1]
  def change
    create_table :reactions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :reactable, polymorphic: true, null: false
      t.integer :reaction_type, default: 0, null: false

      t.timestamps

      t.index [:reactable_type, :reactable_id]
      t.index [:user_id, :reactable_type, :reactable_id], unique: true, name: "index_reactions_on_user_and_reactable"
    end
  end
end
