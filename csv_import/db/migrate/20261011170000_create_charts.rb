class CreateCharts < ActiveRecord::Migration[8.0]
  def change
    create_table :charts do |t|
      t.references :cat_import, null: false, foreign_key: true
      t.references :chat, foreign_key: true
      t.text :prompt, null: false
      t.string :status, null: false, default: "pending"
      t.string :title
      t.text :summary
      t.text :error_message
      t.timestamps
    end
  end
end
