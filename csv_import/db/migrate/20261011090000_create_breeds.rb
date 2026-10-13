class CreateBreeds < ActiveRecord::Migration[8.0]
  def change
    create_table :breeds do |t|
      t.references :import, null: false, foreign_key: true
      t.string :name, null: false
      t.string :origin, null: false
      t.decimal :weight_min, precision: 6, scale: 2, null: false
      t.decimal :weight_max, precision: 6, scale: 2, null: false
      t.timestamps
    end
  end
end
