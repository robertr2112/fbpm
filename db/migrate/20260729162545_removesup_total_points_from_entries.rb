class RemovesupTotalPointsFromEntries < ActiveRecord::Migration[8.0]
  def up
    return unless table_exists?(:entries)
    return unless column_exists?(:entries, :supTotalPoints)

    remove_column :entries, :supTotalPoints, :integer
  end

  def down
    return unless table_exists?(:entries)
    return if column_exists?(:entries, :supTotalPoints)

    add_column :entries, :supTotalPoints, :integer, default: 0
  end
end
