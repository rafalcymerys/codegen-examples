# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_10_11_170000) do
  create_table "agent_events", force: :cascade do |t|
    t.integer "subject_id", null: false
    t.string "kind", null: false
    t.text "message", null: false
    t.text "detail"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "subject_type", null: false
    t.index ["subject_type", "subject_id"], name: "index_agent_events_on_subject_type_and_subject_id"
  end

  create_table "agent_questions", force: :cascade do |t|
    t.integer "subject_id", null: false
    t.string "tool_call_id", null: false
    t.text "question", null: false
    t.text "answer"
    t.datetime "answered_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "subject_type", null: false
    t.index ["subject_type", "subject_id"], name: "index_agent_questions_on_subject_type_and_subject_id"
    t.index ["tool_call_id"], name: "index_agent_questions_on_tool_call_id", unique: true
  end

  create_table "breed_assignments", force: :cascade do |t|
    t.integer "cat_import_id", null: false
    t.integer "chat_id"
    t.string "status", default: "pending", null: false
    t.text "summary"
    t.text "error_message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cat_import_id"], name: "index_breed_assignments_on_cat_import_id"
    t.index ["chat_id"], name: "index_breed_assignments_on_chat_id"
  end

  create_table "breed_imports", force: :cascade do |t|
    t.integer "cat_import_id", null: false
    t.integer "chat_id"
    t.string "status", default: "pending", null: false
    t.string "url", null: false
    t.text "summary"
    t.text "error_message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cat_import_id"], name: "index_breed_imports_on_cat_import_id"
    t.index ["chat_id"], name: "index_breed_imports_on_chat_id"
  end

  create_table "breeds", force: :cascade do |t|
    t.integer "cat_import_id", null: false
    t.string "name", null: false
    t.string "origin", null: false
    t.decimal "weight_min", precision: 6, scale: 2, null: false
    t.decimal "weight_max", precision: 6, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cat_import_id"], name: "index_breeds_on_cat_import_id"
  end

  create_table "cat_imports", force: :cascade do |t|
    t.string "name", null: false
    t.string "status", default: "pending", null: false
    t.string "original_filename", null: false
    t.integer "byte_size", default: 0, null: false
    t.text "summary"
    t.text "error_message"
    t.integer "chat_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chat_id"], name: "index_cat_imports_on_chat_id"
  end

  create_table "cats", force: :cascade do |t|
    t.integer "cat_import_id", null: false
    t.string "name", null: false
    t.string "owner_first_name", null: false
    t.string "owner_last_name", null: false
    t.string "street", null: false
    t.string "zipcode", null: false
    t.string "city", null: false
    t.date "birthday", null: false
    t.string "gender", null: false
    t.string "favorite_food", null: false
    t.date "last_vet_visit", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "breed_name", null: false
    t.integer "breed_id"
    t.decimal "weight", precision: 6, scale: 2, null: false
    t.index ["breed_id"], name: "index_cats_on_breed_id"
    t.index ["cat_import_id"], name: "index_cats_on_cat_import_id"
  end

  create_table "charts", force: :cascade do |t|
    t.integer "cat_import_id", null: false
    t.integer "chat_id"
    t.text "prompt", null: false
    t.string "status", default: "pending", null: false
    t.string "title"
    t.text "summary"
    t.text "error_message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cat_import_id"], name: "index_charts_on_cat_import_id"
    t.index ["chat_id"], name: "index_charts_on_chat_id"
  end

  create_table "chats", force: :cascade do |t|
    t.bigint "ruby_llm_model_id", null: false
    t.boolean "cancelled", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ruby_llm_model_id"], name: "index_chats_on_ruby_llm_model_id"
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "chat_id", null: false
    t.string "role", null: false
    t.text "content"
    t.boolean "cache_until_here", default: false, null: false
    t.string "cache_ttl"
    t.text "thinking_text"
    t.text "thinking_signature"
    t.json "citations"
    t.json "server_tool_calls"
    t.json "raw_content"
    t.json "raw_reasoning"
    t.string "finish_reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chat_id"], name: "index_messages_on_chat_id"
  end

  create_table "reports", force: :cascade do |t|
    t.integer "cat_import_id", null: false
    t.integer "chat_id"
    t.text "prompt", null: false
    t.string "status", default: "pending", null: false
    t.string "title"
    t.text "summary"
    t.text "error_message"
    t.json "columns"
    t.json "rows"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cat_import_id"], name: "index_reports_on_cat_import_id"
    t.index ["chat_id"], name: "index_reports_on_chat_id"
  end

  create_table "ruby_llm_batches", force: :cascade do |t|
    t.string "provider_batch_id", null: false
    t.string "provider", null: false
    t.string "status", null: false
    t.string "raw_status"
    t.boolean "completed", default: false, null: false
    t.string "chat_type"
    t.string "batch_protocol"
    t.json "chat_ids", default: []
    t.json "request_counts"
    t.json "reported_cost"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider", "provider_batch_id"], name: "index_ruby_llm_batches_on_provider_and_provider_batch_id", unique: true
    t.index ["status"], name: "index_ruby_llm_batches_on_status"
  end

  create_table "ruby_llm_mcp_credentials", force: :cascade do |t|
    t.string "owner_type"
    t.bigint "owner_id"
    t.string "key", null: false
    t.text "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_ruby_llm_mcp_credentials_on_key", unique: true
    t.index ["owner_type", "owner_id"], name: "index_ruby_llm_mcp_credentials_on_owner"
  end

  create_table "ruby_llm_models", force: :cascade do |t|
    t.string "model_id", null: false
    t.string "name", null: false
    t.string "provider", null: false
    t.string "family"
    t.datetime "model_created_at"
    t.integer "context_window"
    t.integer "max_output_tokens"
    t.date "knowledge_cutoff"
    t.datetime "unlisted_at"
    t.json "modalities", default: {}
    t.json "capabilities", default: []
    t.json "pricing", default: {}
    t.json "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["family"], name: "index_ruby_llm_models_on_family"
    t.index ["provider", "model_id"], name: "index_ruby_llm_models_on_provider_and_model_id", unique: true
    t.index ["provider"], name: "index_ruby_llm_models_on_provider"
  end

  create_table "ruby_llm_provider_files", force: :cascade do |t|
    t.string "blob_key", null: false
    t.string "provider", null: false
    t.string "account", null: false
    t.text "file_id", null: false
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["blob_key", "provider", "account"], name: "index_ruby_llm_provider_files_uniqueness", unique: true
  end

  create_table "ruby_llm_tool_calls", force: :cascade do |t|
    t.string "message_type", null: false
    t.bigint "message_id", null: false
    t.string "result_type"
    t.bigint "result_id"
    t.string "tool_call_id", null: false
    t.string "name", null: false
    t.text "thought_signature"
    t.string "approval"
    t.boolean "remote", default: false, null: false
    t.json "arguments", default: {}
    t.json "mcp_state"
    t.json "mcp_result"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["message_type", "message_id"], name: "index_ruby_llm_tool_calls_on_message_type_and_message_id"
    t.index ["name"], name: "index_ruby_llm_tool_calls_on_name"
    t.index ["result_type", "result_id"], name: "index_ruby_llm_tool_calls_on_result_type_and_result_id"
    t.index ["tool_call_id"], name: "index_ruby_llm_tool_calls_on_tool_call_id", unique: true
  end

  create_table "ruby_llm_usages", force: :cascade do |t|
    t.string "chat_type"
    t.bigint "chat_id"
    t.string "message_type"
    t.bigint "message_id"
    t.string "owner_type"
    t.bigint "owner_id"
    t.string "operation", null: false
    t.string "provider", null: false
    t.string "model", null: false
    t.string "status", null: false
    t.integer "input_tokens"
    t.integer "output_tokens"
    t.integer "cache_read_tokens"
    t.integer "cache_write_tokens"
    t.integer "thinking_tokens"
    t.json "server_tool_use"
    t.decimal "input_cost", precision: 16, scale: 10
    t.decimal "output_cost", precision: 16, scale: 10
    t.decimal "cache_read_cost", precision: 16, scale: 10
    t.decimal "cache_write_cost", precision: 16, scale: 10
    t.decimal "thinking_cost", precision: 16, scale: 10
    t.decimal "total_cost", precision: 16, scale: 10
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chat_type", "chat_id"], name: "index_ruby_llm_usages_on_chat_type_and_chat_id"
    t.index ["message_type", "message_id"], name: "index_ruby_llm_usages_on_message_type_and_message_id"
    t.index ["owner_type", "owner_id"], name: "index_ruby_llm_usages_on_owner_type_and_owner_id"
    t.index ["status"], name: "index_ruby_llm_usages_on_status"
    t.check_constraint "operation IN ('chat', 'embedding', 'moderation', 'image', 'speech', 'transcription', 'ocr', 'rerank', 'judgment', 'video', 'research')"
    t.check_constraint "status IN ('pending', 'succeeded', 'failed', 'cancelled')"
  end

  add_foreign_key "breed_assignments", "cat_imports"
  add_foreign_key "breed_assignments", "chats"
  add_foreign_key "breed_imports", "cat_imports"
  add_foreign_key "breed_imports", "chats"
  add_foreign_key "breeds", "cat_imports"
  add_foreign_key "cat_imports", "chats"
  add_foreign_key "cats", "breeds"
  add_foreign_key "cats", "cat_imports"
  add_foreign_key "charts", "cat_imports"
  add_foreign_key "charts", "chats"
  add_foreign_key "chats", "ruby_llm_models"
  add_foreign_key "messages", "chats"
  add_foreign_key "reports", "cat_imports"
  add_foreign_key "reports", "chats"
end
