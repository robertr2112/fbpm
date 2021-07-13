class AddPoolDoneToPool < ActiveRecord::Migration[4.2]
  def change
    add_column :pools, :pool_done, :boolean, default: false
  end
end
