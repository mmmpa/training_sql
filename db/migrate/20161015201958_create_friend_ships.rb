class CreateFriendShips < ActiveRecord::Migration[5.0]
  def change
    create_table :friend_ships do |t|
      t.integer :owner_id
      t.integer :ownee_id

      t.timestamps
    end
  end
end
