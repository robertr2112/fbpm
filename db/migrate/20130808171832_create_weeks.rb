class CreateWeeks < ActiveRecord::Migration[4.2]
  def change
    create_table :weeks do |t|
      t.belongs_to :season
      t.integer    :state
      t.integer    :week_number

      t.timestamps
    end
  end
end
