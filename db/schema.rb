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

ActiveRecord::Schema[8.1].define(version: 2026_04_08_135744) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "appointments", force: :cascade do |t|
    t.date "appointment_date"
    t.integer "appointment_type", default: 0, null: false
    t.integer "beneficiary_id", null: false
    t.string "court"
    t.string "court_section"
    t.datetime "created_at", null: false
    t.date "decree_date"
    t.string "decree_number"
    t.decimal "extraordinary_expense_limit", precision: 12, scale: 2
    t.text "financial_powers"
    t.string "judge"
    t.date "mandate_expiry_date"
    t.text "notes"
    t.decimal "ordinary_expense_limit", precision: 12, scale: 2
    t.text "personal_powers"
    t.datetime "updated_at", null: false
    t.index ["beneficiary_id"], name: "index_appointments_on_beneficiary_id"
  end

  create_table "assets", force: :cascade do |t|
    t.integer "asset_type", default: 0, null: false
    t.integer "beneficiary_id", null: false
    t.datetime "created_at", null: false
    t.decimal "current_value", precision: 12, scale: 2
    t.string "description", null: false
    t.decimal "initial_value", precision: 12, scale: 2
    t.string "institution_or_location"
    t.text "notes"
    t.datetime "updated_at", null: false
    t.date "valuation_date"
    t.index ["beneficiary_id"], name: "index_assets_on_beneficiary_id"
  end

  create_table "beneficiaries", force: :cascade do |t|
    t.string "city"
    t.datetime "created_at", null: false
    t.date "date_of_birth"
    t.text "diagnosis"
    t.string "doctor_contact"
    t.string "first_name", null: false
    t.integer "gender", default: 0, null: false
    t.text "health_condition"
    t.string "last_name", null: false
    t.text "notes"
    t.string "place_of_birth"
    t.string "province"
    t.string "referring_doctor"
    t.integer "status", default: 0, null: false
    t.string "street_address"
    t.string "tax_code"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.string "zip_code"
    t.index ["status"], name: "index_beneficiaries_on_status"
    t.index ["tax_code"], name: "index_beneficiaries_on_tax_code"
    t.index ["user_id"], name: "index_beneficiaries_on_user_id"
  end

  create_table "communications", force: :cascade do |t|
    t.integer "beneficiary_id", null: false
    t.text "body"
    t.integer "channel", default: 0, null: false
    t.string "counterpart"
    t.datetime "created_at", null: false
    t.date "sent_at"
    t.integer "status", default: 0, null: false
    t.string "subject", null: false
    t.datetime "updated_at", null: false
    t.index ["beneficiary_id"], name: "index_communications_on_beneficiary_id"
  end

  create_table "contacts", force: :cascade do |t|
    t.integer "beneficiary_id", null: false
    t.datetime "created_at", null: false
    t.string "email"
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.text "notes"
    t.string "phone"
    t.string "relationship"
    t.datetime "updated_at", null: false
    t.index ["beneficiary_id"], name: "index_contacts_on_beneficiary_id"
  end

  create_table "deadlines", force: :cascade do |t|
    t.integer "beneficiary_id", null: false
    t.datetime "created_at", null: false
    t.integer "deadline_type", default: 0, null: false
    t.text "description"
    t.date "due_date", null: false
    t.integer "priority", default: 1, null: false
    t.date "reminder_date"
    t.integer "status", default: 0, null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["beneficiary_id"], name: "index_deadlines_on_beneficiary_id"
    t.index ["due_date"], name: "index_deadlines_on_due_date"
    t.index ["status"], name: "index_deadlines_on_status"
  end

  create_table "documents", force: :cascade do |t|
    t.integer "beneficiary_id", null: false
    t.datetime "created_at", null: false
    t.date "document_date"
    t.integer "document_type", default: 0, null: false
    t.date "expiry_date"
    t.text "notes"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["beneficiary_id"], name: "index_documents_on_beneficiary_id"
  end

  create_table "expense_entries", force: :cascade do |t|
    t.decimal "amount", precision: 12, scale: 2, null: false
    t.integer "category", default: 0, null: false
    t.datetime "created_at", null: false
    t.string "description", null: false
    t.date "entry_date", null: false
    t.string "receipt_number"
    t.integer "report_id", null: false
    t.string "supplier"
    t.datetime "updated_at", null: false
    t.index ["report_id"], name: "index_expense_entries_on_report_id"
  end

  create_table "hearings", force: :cascade do |t|
    t.integer "appointment_id"
    t.integer "beneficiary_id", null: false
    t.string "court"
    t.string "courtroom"
    t.datetime "created_at", null: false
    t.datetime "hearing_date", null: false
    t.date "next_hearing_date"
    t.text "notes"
    t.text "outcome"
    t.string "subject"
    t.datetime "updated_at", null: false
    t.index ["appointment_id"], name: "index_hearings_on_appointment_id"
    t.index ["beneficiary_id"], name: "index_hearings_on_beneficiary_id"
  end

  create_table "income_entries", force: :cascade do |t|
    t.decimal "amount", precision: 12, scale: 2, null: false
    t.integer "category", default: 0, null: false
    t.datetime "created_at", null: false
    t.string "description", null: false
    t.date "entry_date", null: false
    t.integer "report_id", null: false
    t.string "source"
    t.datetime "updated_at", null: false
    t.index ["report_id"], name: "index_income_entries_on_report_id"
  end

  create_table "liabilities", force: :cascade do |t|
    t.integer "beneficiary_id", null: false
    t.datetime "created_at", null: false
    t.string "creditor"
    t.string "description"
    t.date "end_date"
    t.decimal "initial_amount", precision: 15, scale: 2
    t.decimal "interest_rate", precision: 5, scale: 2
    t.integer "liability_type"
    t.decimal "monthly_payment", precision: 10, scale: 2
    t.text "notes"
    t.decimal "remaining_balance", precision: 15, scale: 2
    t.date "start_date"
    t.datetime "updated_at", null: false
    t.index ["beneficiary_id"], name: "index_liabilities_on_beneficiary_id"
  end

  create_table "noticed_events", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "notifications_count"
    t.json "params"
    t.bigint "record_id"
    t.string "record_type"
    t.string "type"
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id"], name: "index_noticed_events_on_record"
  end

  create_table "noticed_notifications", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "event_id", null: false
    t.datetime "read_at", precision: nil
    t.bigint "recipient_id", null: false
    t.string "recipient_type", null: false
    t.datetime "seen_at", precision: nil
    t.string "type"
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_noticed_notifications_on_event_id"
    t.index ["recipient_type", "recipient_id"], name: "index_noticed_notifications_on_recipient"
  end

  create_table "properties", force: :cascade do |t|
    t.string "address"
    t.integer "beneficiary_id", null: false
    t.string "cadastral_category"
    t.string "cadastral_class"
    t.string "cadastral_consistency"
    t.decimal "cadastral_income", precision: 10, scale: 2
    t.string "cadastral_particle"
    t.string "cadastral_sheet"
    t.string "cadastral_sub"
    t.string "city"
    t.datetime "created_at", null: false
    t.decimal "current_value", precision: 12, scale: 2
    t.string "description", null: false
    t.decimal "initial_value", precision: 12, scale: 2
    t.text "notes"
    t.integer "ownership_denominator"
    t.integer "ownership_numerator"
    t.integer "property_type", default: 0, null: false
    t.string "province"
    t.datetime "updated_at", null: false
    t.date "valuation_date"
    t.string "zip_code"
    t.index ["beneficiary_id"], name: "index_properties_on_beneficiary_id"
  end

  create_table "recurring_expenses", force: :cascade do |t|
    t.boolean "active", default: true
    t.decimal "amount", precision: 10, scale: 2
    t.integer "beneficiary_id", null: false
    t.datetime "created_at", null: false
    t.string "description"
    t.date "end_date"
    t.integer "expense_type"
    t.integer "frequency"
    t.text "notes"
    t.date "start_date"
    t.datetime "updated_at", null: false
    t.index ["beneficiary_id"], name: "index_recurring_expenses_on_beneficiary_id"
  end

  create_table "recurring_incomes", force: :cascade do |t|
    t.boolean "active", default: true
    t.decimal "amount", precision: 10, scale: 2
    t.integer "beneficiary_id", null: false
    t.datetime "created_at", null: false
    t.string "description"
    t.date "end_date"
    t.integer "frequency"
    t.integer "income_type"
    t.text "notes"
    t.date "start_date"
    t.datetime "updated_at", null: false
    t.index ["beneficiary_id"], name: "index_recurring_incomes_on_beneficiary_id"
  end

  create_table "reports", force: :cascade do |t|
    t.integer "appointment_id", null: false
    t.integer "beneficiary_id", null: false
    t.text "court_notes"
    t.datetime "created_at", null: false
    t.date "filing_date"
    t.date "period_from", null: false
    t.date "period_to", null: false
    t.integer "reference_year", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["appointment_id"], name: "index_reports_on_appointment_id"
    t.index ["beneficiary_id", "reference_year"], name: "index_reports_on_beneficiary_id_and_reference_year"
    t.index ["beneficiary_id"], name: "index_reports_on_beneficiary_id"
  end

  create_table "solid_cable_messages", force: :cascade do |t|
    t.binary "channel", limit: 1024, null: false
    t.integer "channel_hash", limit: 8, null: false
    t.datetime "created_at", null: false
    t.binary "payload", limit: 536870912, null: false
    t.index ["channel"], name: "index_solid_cable_messages_on_channel"
    t.index ["channel_hash"], name: "index_solid_cable_messages_on_channel_hash"
    t.index ["created_at"], name: "index_solid_cable_messages_on_created_at"
  end

  create_table "solid_queue_blocked_executions", force: :cascade do |t|
    t.string "concurrency_key", null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.index ["concurrency_key", "priority", "job_id"], name: "index_solid_queue_blocked_executions_for_release"
    t.index ["expires_at", "concurrency_key"], name: "index_solid_queue_blocked_executions_for_maintenance"
    t.index ["job_id"], name: "index_solid_queue_blocked_executions_on_job_id", unique: true
  end

  create_table "solid_queue_claimed_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.bigint "process_id"
    t.index ["job_id"], name: "index_solid_queue_claimed_executions_on_job_id", unique: true
    t.index ["process_id", "job_id"], name: "index_solid_queue_claimed_executions_on_process_id_and_job_id"
  end

  create_table "solid_queue_failed_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "error"
    t.bigint "job_id", null: false
    t.index ["job_id"], name: "index_solid_queue_failed_executions_on_job_id", unique: true
  end

  create_table "solid_queue_jobs", force: :cascade do |t|
    t.string "active_job_id"
    t.text "arguments"
    t.string "class_name", null: false
    t.string "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "finished_at"
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.datetime "scheduled_at"
    t.datetime "updated_at", null: false
    t.index ["active_job_id"], name: "index_solid_queue_jobs_on_active_job_id"
    t.index ["class_name"], name: "index_solid_queue_jobs_on_class_name"
    t.index ["finished_at"], name: "index_solid_queue_jobs_on_finished_at"
    t.index ["queue_name", "finished_at"], name: "index_solid_queue_jobs_for_filtering"
    t.index ["scheduled_at", "finished_at"], name: "index_solid_queue_jobs_for_alerting"
  end

  create_table "solid_queue_pauses", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "queue_name", null: false
    t.index ["queue_name"], name: "index_solid_queue_pauses_on_queue_name", unique: true
  end

  create_table "solid_queue_processes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "hostname"
    t.string "kind", null: false
    t.datetime "last_heartbeat_at", null: false
    t.text "metadata"
    t.string "name", null: false
    t.integer "pid", null: false
    t.bigint "supervisor_id"
    t.index ["last_heartbeat_at"], name: "index_solid_queue_processes_on_last_heartbeat_at"
    t.index ["name", "supervisor_id"], name: "index_solid_queue_processes_on_name_and_supervisor_id", unique: true
    t.index ["supervisor_id"], name: "index_solid_queue_processes_on_supervisor_id"
  end

  create_table "solid_queue_ready_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.index ["job_id"], name: "index_solid_queue_ready_executions_on_job_id", unique: true
    t.index ["priority", "job_id"], name: "index_solid_queue_poll_all"
    t.index ["queue_name", "priority", "job_id"], name: "index_solid_queue_poll_by_queue"
  end

  create_table "solid_queue_recurring_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.datetime "run_at", null: false
    t.string "task_key", null: false
    t.index ["job_id"], name: "index_solid_queue_recurring_executions_on_job_id", unique: true
    t.index ["task_key", "run_at"], name: "index_solid_queue_recurring_executions_on_task_key_and_run_at", unique: true
  end

  create_table "solid_queue_recurring_tasks", force: :cascade do |t|
    t.text "arguments"
    t.string "class_name"
    t.string "command", limit: 2048
    t.datetime "created_at", null: false
    t.text "description"
    t.string "key", null: false
    t.integer "priority", default: 0
    t.string "queue_name"
    t.string "schedule", null: false
    t.boolean "static", default: true, null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_solid_queue_recurring_tasks_on_key", unique: true
    t.index ["static"], name: "index_solid_queue_recurring_tasks_on_static"
  end

  create_table "solid_queue_scheduled_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.datetime "scheduled_at", null: false
    t.index ["job_id"], name: "index_solid_queue_scheduled_executions_on_job_id", unique: true
    t.index ["scheduled_at", "priority", "job_id"], name: "index_solid_queue_dispatch_all"
  end

  create_table "solid_queue_semaphores", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.string "key", null: false
    t.datetime "updated_at", null: false
    t.integer "value", default: 1, null: false
    t.index ["expires_at"], name: "index_solid_queue_semaphores_on_expires_at"
    t.index ["key", "value"], name: "index_solid_queue_semaphores_on_key_and_value"
    t.index ["key"], name: "index_solid_queue_semaphores_on_key", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.integer "account_type", default: 0, null: false
    t.string "address"
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "phone"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "role", default: 0, null: false
    t.string "tax_code"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "appointments", "beneficiaries"
  add_foreign_key "assets", "beneficiaries"
  add_foreign_key "beneficiaries", "users"
  add_foreign_key "communications", "beneficiaries"
  add_foreign_key "contacts", "beneficiaries"
  add_foreign_key "deadlines", "beneficiaries"
  add_foreign_key "documents", "beneficiaries"
  add_foreign_key "expense_entries", "reports"
  add_foreign_key "hearings", "appointments"
  add_foreign_key "hearings", "beneficiaries"
  add_foreign_key "income_entries", "reports"
  add_foreign_key "liabilities", "beneficiaries"
  add_foreign_key "properties", "beneficiaries"
  add_foreign_key "recurring_expenses", "beneficiaries"
  add_foreign_key "recurring_incomes", "beneficiaries"
  add_foreign_key "reports", "appointments"
  add_foreign_key "reports", "beneficiaries"
  add_foreign_key "solid_queue_blocked_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_claimed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_failed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_ready_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_recurring_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_scheduled_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
end
