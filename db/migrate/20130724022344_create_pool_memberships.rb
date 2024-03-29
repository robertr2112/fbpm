class CreatePoolMemberships < ActiveRecord::Migration[4.2]
  def change
    create_table :pool_memberships do |t|
      t.integer :user_id
      t.integer :pool_id
      t.boolean :owner, null: false, default: false

      t.timestamps
    end
  end
end
