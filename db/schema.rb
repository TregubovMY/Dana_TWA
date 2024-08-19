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

ActiveRecord::Schema[7.1].define(version: 2024_08_15_111811) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "banks", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_banks_on_deleted_at"
    t.index ["name"], name: "index_banks_on_name", unique: true
  end

  create_table "categories", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_categories_on_deleted_at"
    t.index ["name"], name: "index_categories_on_name"
  end

  create_table "mailing_settings", force: :cascade do |t|
    t.string "phone", null: false
    t.bigint "bank_id", null: false
    t.boolean "active", default: false
    t.datetime "deleted_at"
    t.index ["bank_id"], name: "index_mailing_settings_on_bank_id"
    t.index ["deleted_at"], name: "index_mailing_settings_on_deleted_at"
  end

  create_table "mailings", force: :cascade do |t|
    t.bigint "mailing_setting_id", null: false
    t.integer "kind"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_mailings_on_deleted_at"
    t.index ["mailing_setting_id"], name: "index_mailings_on_mailing_setting_id"
  end

  create_table "orders", force: :cascade do |t|
    t.integer "state", default: 0, null: false
    t.bigint "product_id", null: false
    t.bigint "user_id", null: false
    t.datetime "cancelable_until"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_orders_on_deleted_at"
    t.index ["product_id"], name: "index_orders_on_product_id"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "payments", force: :cascade do |t|
    t.integer "state", default: 0, null: false
    t.decimal "amount", null: false
    t.bigint "order_id", null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_payments_on_deleted_at"
    t.index ["order_id"], name: "index_payments_on_order_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.decimal "price", default: "0.0", null: false
    t.integer "quantity", default: 0, null: false
    t.datetime "deleted_at"
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_products_on_category_id"
    t.index ["name"], name: "index_products_on_name", unique: true
  end

  create_table "roles", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_roles_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "username", default: "", null: false
    t.string "telegram_chat_id", default: "", null: false
    t.string "telegram_username", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.decimal "deposit", default: "0.0", null: false
    t.boolean "approve", default: false
    t.datetime "deleted_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_users_on_deleted_at"
    t.index ["telegram_chat_id"], name: "index_users_on_telegram_chat_id", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "users_roles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "role_id", null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_users_roles_on_deleted_at"
    t.index ["role_id"], name: "index_users_roles_on_role_id"
    t.index ["user_id"], name: "index_users_roles_on_user_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "mailing_settings", "banks"
  add_foreign_key "mailings", "mailing_settings"
  add_foreign_key "orders", "products"
  add_foreign_key "orders", "users"
  add_foreign_key "payments", "orders"
  add_foreign_key "products", "categories"
  add_foreign_key "users_roles", "roles"
  add_foreign_key "users_roles", "users"
end
