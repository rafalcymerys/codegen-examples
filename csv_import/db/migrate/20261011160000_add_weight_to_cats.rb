class AddWeightToCats < ActiveRecord::Migration[8.0]
  def change
    add_column :cats, :weight, :decimal, precision: 6, scale: 2, null: false
  end
end
