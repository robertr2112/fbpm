class AddGameDateToGames < ActiveRecord::Migration[4.2]
  def change
    add_column :games, :game_date, :datetime
  end
end
