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

ActiveRecord::Schema[7.2].define(version: 2026_03_18_123146) do
  create_table "attivita", force: :cascade do |t|
    t.integer "procedimento_id", null: false
    t.string "titolo"
    t.text "descrizione"
    t.datetime "data_attivita"
    t.string "tipo"
    t.boolean "completata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["procedimento_id"], name: "index_attivita_on_procedimento_id"
  end

  create_table "beneficiari", force: :cascade do |t|
    t.string "nome"
    t.string "cognome"
    t.string "codice_fiscale"
    t.date "data_nascita"
    t.string "luogo_nascita"
    t.string "indirizzo"
    t.string "telefono"
    t.string "email"
    t.text "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "procedimenti", force: :cascade do |t|
    t.integer "beneficiario_id", null: false
    t.string "numero_rg"
    t.string "tribunale"
    t.string "giudice_tutelare"
    t.date "data_apertura"
    t.date "data_chiusura"
    t.string "stato"
    t.text "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["beneficiario_id"], name: "index_procedimenti_on_beneficiario_id"
  end

  create_table "rendiconti", force: :cascade do |t|
    t.integer "procedimento_id", null: false
    t.integer "anno"
    t.date "data_presentazione"
    t.date "data_approvazione"
    t.string "stato"
    t.text "note"
    t.decimal "importo_entrate"
    t.decimal "importo_uscite"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["procedimento_id"], name: "index_rendiconti_on_procedimento_id"
  end

  create_table "scadenze", force: :cascade do |t|
    t.integer "procedimento_id", null: false
    t.string "titolo"
    t.text "descrizione"
    t.date "data_scadenza"
    t.boolean "completata"
    t.string "tipo"
    t.text "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["procedimento_id"], name: "index_scadenze_on_procedimento_id"
  end

  create_table "udienze", force: :cascade do |t|
    t.integer "procedimento_id", null: false
    t.datetime "data_udienza"
    t.string "tipo"
    t.string "luogo"
    t.text "note"
    t.text "esito"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["procedimento_id"], name: "index_udienze_on_procedimento_id"
  end

  add_foreign_key "attivita", "procedimenti"
  add_foreign_key "procedimenti", "beneficiari"
  add_foreign_key "rendiconti", "procedimenti"
  add_foreign_key "scadenze", "procedimenti"
  add_foreign_key "udienze", "procedimenti"
end
