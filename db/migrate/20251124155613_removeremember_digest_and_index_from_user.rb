class RemoverememberDigestAndIndexFromUser < ActiveRecord::Migration[8.0]
  def change
    # Remove the index
    remove_index :users, :remember_digest

   # Remove RememberDigest
   remove_column :users, :remember_digest, :string
  end
end
