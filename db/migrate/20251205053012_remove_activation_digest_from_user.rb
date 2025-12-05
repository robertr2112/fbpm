class RemoveActivationDigestFromUser < ActiveRecord::Migration[8.0]
  def change
   # Remove ActivationDigest
   remove_column :users, :activation_digest, :string
  end
end
