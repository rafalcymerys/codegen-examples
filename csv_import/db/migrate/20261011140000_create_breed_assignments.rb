class CreateBreedAssignments < ActiveRecord::Migration[8.0]
  def change
    create_table :breed_assignments do |t|
      t.references :cat_import, null: false, foreign_key: true
      t.references :chat, foreign_key: true
      t.string :status, null: false, default: "pending"
      t.text :summary
      t.text :error_message
      t.timestamps
    end
  end
end
