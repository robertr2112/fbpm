class AddGameDateToGames < ActiveRecord::Migration[5.2]
  def change
    add_column :games, :game_date, :datetime
  end
end
