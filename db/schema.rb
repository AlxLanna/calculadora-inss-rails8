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

ActiveRecord::Schema[8.0].define(version: 2025_05_26_170605) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "contatos", force: :cascade do |t|
    t.string "tipo"
    t.string "valor"
    t.bigint "proponente_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["proponente_id"], name: "index_contatos_on_proponente_id"
  end

  create_table "enderecos", force: :cascade do |t|
    t.string "logradouro"
    t.string "numero"
    t.string "bairro"
    t.string "cidade"
    t.string "estado"
    t.string "cep"
    t.bigint "proponente_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["proponente_id"], name: "index_enderecos_on_proponente_id"
  end

  create_table "proponentes", force: :cascade do |t|
    t.string "nome"
    t.string "documentos"
    t.date "data_nascimento"
    t.decimal "salario"
    t.decimal "desconto_inss"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "contatos", "proponentes"
  add_foreign_key "enderecos", "proponentes"
end
