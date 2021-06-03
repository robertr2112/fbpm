class CreateGames < ActiveRecord::Migration[5.2]
  def change
    create_table :games do |t|
      t.integer :homeTeamIndex
      t.integer :awayTeamIndex
      t.integer :spread
      t.belongs_to :week, foreign_key: true
      t.integer :homeTeamScore, default: 0
      t.integer :awayTeamScore, default: 0

      t.timestamps
    end
  end
end
