class CreateWeeks < ActiveRecord::Migration[5.2]
  def change
    create_table :weeks do |t|
      t.integer :state, default: 0
      t.integer :week_number
      t.belongs_to :season, foreign_key: true

      t.timestamps
    end
  end
end
