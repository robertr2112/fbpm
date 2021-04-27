class CreateGames < ActiveRecord::Migration[5.2]
  def change
    create_table :games do |t|
      t.belongs_to :week, foreign_key: true
      t.integer :homeTeamIndex
      t.integer :awayTeamIndex
      t.integer :spread
      t.integer :homeTeamScore
      t.integer :awayTeamScore
      t.datetime :game_date

      t.timestamps
    end
  end
end
