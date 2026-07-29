class AddDefaultToPoolTypeInPools < ActiveRecord::Migration[8.0]
  def change
    change_column_default :pools, :pool_type, from: nil, to: 2
  end
end
