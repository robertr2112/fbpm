class AddContactToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :contact, :integer, default: 1
  end
end
