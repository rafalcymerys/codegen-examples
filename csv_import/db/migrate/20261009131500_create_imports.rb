class CreateImports < ActiveRecord::Migration[8.0]
  def change
    create_table :imports do |t|
      t.string :name, null: false
      t.string :status, null: false, default: "pending"
      t.string :original_filename, null: false
      t.integer :byte_size, null: false, default: 0
      t.text :summary
      t.text :error_message
      t.references :chat, foreign_key: true
      t.timestamps
    end

    create_table :cats do |t|
      t.references :import, null: false, foreign_key: true
      t.string :name, null: false
      t.string :owner_first_name
      t.string :owner_last_name
      t.string :street
      t.string :zipcode
      t.string :city
      t.date :birthday
      t.string :gender
      t.string :favorite_food
      t.date :last_vet_visit
      t.timestamps
    end

    create_table :import_questions do |t|
      t.references :import, null: false, foreign_key: true
      t.string :tool_call_id, null: false, index: { unique: true }
      t.text :question, null: false
      t.text :answer
      t.datetime :answered_at
      t.timestamps
    end

    create_table :import_events do |t|
      t.references :import, null: false, foreign_key: true
      t.string :kind, null: false
      t.text :message, null: false
      t.text :detail
      t.timestamps
    end
  end
end
