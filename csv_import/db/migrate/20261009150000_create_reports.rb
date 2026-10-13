class CreateReports < ActiveRecord::Migration[8.0]
  def change
    # Questions and the activity log are now shared by imports and reports.
    { import_events: :agent_events, import_questions: :agent_questions }.each do |old_name, new_name|
      rename_table old_name, new_name
      remove_foreign_key new_name, :imports
      rename_column new_name, :import_id, :subject_id
      add_column new_name, :subject_type, :string, null: false, default: "Import"
      change_column_default new_name, :subject_type, from: "Import", to: nil
      remove_index new_name, :subject_id
      add_index new_name, [ :subject_type, :subject_id ]
    end

    create_table :reports do |t|
      t.references :import, null: false, foreign_key: true
      t.references :chat, foreign_key: true
      t.text :prompt, null: false
      t.string :status, null: false, default: "pending"
      t.string :title
      t.text :summary
      t.text :error_message
      t.json :columns
      t.json :rows
      t.timestamps
    end
  end
end
