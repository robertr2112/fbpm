class RenamepoolTypeTopoolTypeInTablePool < ActiveRecord::Migration[8.0]
  def change
    rename_column :pools, :poolType, :pool_type
  end
end
