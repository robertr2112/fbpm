class RemovepasswordResetfromuser < ActiveRecord::Migration[8.0]
  def change
   # Remove PasswordResetToken
   remove_column :users, :password_reset_token, :string

   # Remove PasswordResetSentAt
   remove_column :users, :password_reset_sent_at, :string
  end
end
