class RemovesupTotalPointsFromEntries < ActiveRecord::Migration[8.0]
  def change
    remove_column :entries, :supTotalPoints, :integer
  end
end
