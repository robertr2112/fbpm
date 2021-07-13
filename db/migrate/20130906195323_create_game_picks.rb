class CreateGamePicks < ActiveRecord::Migration[4.2]
  def change
    create_table :game_picks do |t|
      t.belongs_to :pick
      t.integer    :game_pick_id
      t.integer    :chosenTeamIndex

      t.timestamps
    end
  end
end
