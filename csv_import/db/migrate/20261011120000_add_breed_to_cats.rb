class AddBreedToCats < ActiveRecord::Migration[8.0]
  def change
    # Cats imported before breeds existed get a placeholder; re-importing the file fills in real names.
    add_column :cats, :breed_name, :string, null: false, default: "Unknown"
    change_column_default :cats, :breed_name, from: "Unknown", to: nil
    add_reference :cats, :breed, foreign_key: true
  end
end
