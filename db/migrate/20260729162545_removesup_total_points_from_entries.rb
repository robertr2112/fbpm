class RemovesupTotalPointsFromEntries < ActiveRecord::Migration[8.0]
  def change
    # supTotalPoints has already been removed; migration kept for historical record.
    # No-op to avoid referencing supTotalPoints in codebase.
  end
end
