class ChangeConfirmedToActivated < ActiveRecord::Migration[5.2]
  def change
    rename_column :users, :confirmed, :activated
    rename_column :users, :confirmation_token, :activation_digest
    add_column :users, :activated_at, :datetime
  end
end
