class AddNetworkToGame < ActiveRecord::Migration[5.2]
  def change
    add_column :games, :network, :string
  end
end
