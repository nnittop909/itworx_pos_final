# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170722080029) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.string "type"
    t.string "definition"
    t.boolean "contra"
    t.integer "main_account_id"
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["main_account_id"], name: "index_accounts_on_main_account_id"
  end

  create_table "addresses", force: :cascade do |t|
    t.string "house_number"
    t.string "street"
    t.string "barangay"
    t.string "municipality"
    t.string "province"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_addresses_on_user_id"
  end

  create_table "amounts", force: :cascade do |t|
    t.string "type"
    t.decimal "amount", default: "0.0"
    t.bigint "account_id"
    t.bigint "entry_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_amounts_on_account_id"
    t.index ["entry_id"], name: "index_amounts_on_entry_id"
    t.index ["type"], name: "index_amounts_on_type"
  end

  create_table "businesses", force: :cascade do |t|
    t.string "name"
    t.string "tin"
    t.boolean "vat"
    t.string "address"
    t.string "proprietor"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "logo_file_name"
    t.string "logo_content_type"
    t.integer "logo_file_size"
    t.datetime "logo_updated_at"
  end

  create_table "carts", force: :cascade do |t|
    t.integer "employee_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["employee_id"], name: "index_carts_on_employee_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "catering_carts", force: :cascade do |t|
    t.integer "employee_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["employee_id"], name: "index_catering_carts_on_employee_id"
  end

  create_table "catering_line_items", force: :cascade do |t|
    t.string "name"
    t.string "unit"
    t.integer "quantity"
    t.decimal "unit_cost"
    t.decimal "total_cost"
    t.integer "catering_cart_id"
    t.integer "order_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "discounts", force: :cascade do |t|
    t.decimal "amount", default: "0.0"
    t.integer "discount_type"
    t.integer "order_id"
    t.integer "employee_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["employee_id"], name: "index_discounts_on_employee_id"
  end

  create_table "entries", force: :cascade do |t|
    t.datetime "date"
    t.string "description"
    t.integer "commercial_document_id"
    t.string "commercial_document_type"
    t.integer "user_id"
    t.integer "order_id"
    t.integer "stock_id"
    t.integer "employee_id"
    t.string "reference_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["commercial_document_id"], name: "index_entries_on_commercial_document_id"
    t.index ["commercial_document_type"], name: "index_entries_on_commercial_document_type"
    t.index ["employee_id"], name: "index_entries_on_employee_id"
    t.index ["user_id"], name: "index_entries_on_user_id"
  end

  create_table "interest_programs", force: :cascade do |t|
    t.integer "line_item_id"
    t.decimal "amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["line_item_id"], name: "index_interest_programs_on_line_item_id"
  end

  create_table "invoice_numbers", force: :cascade do |t|
    t.datetime "date"
    t.string "number"
    t.integer "order_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_invoice_numbers_on_order_id"
  end

  create_table "invoices", force: :cascade do |t|
    t.string "number"
    t.string "type"
    t.integer "invoiceable_id"
    t.string "invoiceable_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invoiceable_id"], name: "index_invoices_on_invoiceable_id"
    t.index ["invoiceable_type"], name: "index_invoices_on_invoiceable_type"
    t.index ["type"], name: "index_invoices_on_type"
  end

  create_table "line_items", force: :cascade do |t|
    t.integer "cart_id"
    t.integer "order_id"
    t.integer "user_id"
    t.integer "stock_id"
    t.decimal "quantity", default: "1.0"
    t.decimal "unit_price"
    t.decimal "total_price"
    t.integer "pricing_type", default: 0
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cart_id"], name: "index_line_items_on_cart_id"
    t.index ["deleted_at"], name: "index_line_items_on_deleted_at"
    t.index ["stock_id"], name: "index_line_items_on_stock_id"
    t.index ["user_id"], name: "index_line_items_on_user_id"
  end

  create_table "official_receipt_numbers", force: :cascade do |t|
    t.date "date"
    t.string "number"
    t.integer "order_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_official_receipt_numbers_on_order_id"
  end

  create_table "orders", force: :cascade do |t|
    t.string "name"
    t.datetime "date"
    t.integer "pay_type"
    t.integer "delivery_type"
    t.integer "order_type"
    t.decimal "cash_tendered"
    t.decimal "change"
    t.decimal "tax_amount"
    t.datetime "deleted_at"
    t.boolean "discounted", default: false
    t.string "reference_number"
    t.integer "payment_status"
    t.integer "user_id"
    t.integer "employee_id"
    t.integer "entry_id"
    t.integer "tax_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_orders_on_deleted_at"
    t.index ["employee_id"], name: "index_orders_on_employee_id"
    t.index ["entry_id"], name: "index_orders_on_entry_id"
    t.index ["tax_id"], name: "index_orders_on_tax_id"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.string "unit"
    t.integer "category_id"
    t.string "bar_code"
    t.decimal "retail_price"
    t.decimal "wholesale_price"
    t.string "name_and_description"
    t.decimal "stock_alert_count", default: "1.0"
    t.integer "stock_status"
    t.boolean "program_product", default: false
    t.integer "program_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_products_on_category_id"
    t.index ["description"], name: "index_products_on_description"
    t.index ["name"], name: "index_products_on_name"
    t.index ["program_id"], name: "index_products_on_program_id"
  end

  create_table "program_subscriptions", force: :cascade do |t|
    t.integer "member_id"
    t.bigint "program_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["member_id"], name: "index_program_subscriptions_on_member_id"
    t.index ["program_id"], name: "index_program_subscriptions_on_program_id"
  end

  create_table "programs", force: :cascade do |t|
    t.string "name"
    t.decimal "interest_rate"
    t.integer "number_of_days"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "refunds", force: :cascade do |t|
    t.datetime "date"
    t.decimal "amount"
    t.decimal "quantity"
    t.integer "request_status"
    t.string "remarks"
    t.integer "employee_id"
    t.integer "entry_id"
    t.integer "stock_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["employee_id"], name: "index_refunds_on_employee_id"
    t.index ["entry_id"], name: "index_refunds_on_entry_id"
    t.index ["stock_id"], name: "index_refunds_on_stock_id"
  end

  create_table "stock_transfers", force: :cascade do |t|
    t.integer "entry_id"
    t.integer "stock_id"
    t.integer "supplier_id"
    t.integer "employee_id"
    t.datetime "date"
    t.decimal "amount"
    t.decimal "quantity"
    t.string "remarks"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "stocks", force: :cascade do |t|
    t.string "name"
    t.datetime "date"
    t.decimal "quantity", precision: 8, scale: 2
    t.decimal "unit_cost"
    t.decimal "total_cost"
    t.decimal "retail_price"
    t.decimal "wholesale_price"
    t.date "expiry_date"
    t.string "serial_number"
    t.string "reference_number"
    t.integer "payment_type", default: 0
    t.boolean "discounted", default: false
    t.decimal "discount_amount", default: "0.0"
    t.boolean "has_freight", default: false
    t.decimal "freight_amount", default: "0.0"
    t.boolean "received", default: false
    t.integer "stock_type"
    t.integer "product_id"
    t.integer "supplier_id"
    t.integer "entry_id"
    t.integer "employee_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["employee_id"], name: "index_stocks_on_employee_id"
    t.index ["entry_id"], name: "index_stocks_on_entry_id"
    t.index ["product_id"], name: "index_stocks_on_product_id"
    t.index ["supplier_id"], name: "index_stocks_on_supplier_id"
  end

  create_table "suppliers", force: :cascade do |t|
    t.string "business_name"
    t.string "owner"
    t.string "address"
    t.string "mobile_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "taxes", force: :cascade do |t|
    t.string "name"
    t.integer "tax_type"
    t.decimal "percentage"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "first_name"
    t.string "middle_name"
    t.string "last_name"
    t.string "full_name"
    t.integer "role"
    t.string "type"
    t.string "mobile"
    t.integer "member_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "profile_photo_file_name"
    t.string "profile_photo_content_type"
    t.integer "profile_photo_file_size"
    t.datetime "profile_photo_updated_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["type"], name: "index_users_on_type"
  end

  create_table "warranties", force: :cascade do |t|
    t.string "description"
    t.integer "business_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["business_id"], name: "index_warranties_on_business_id"
  end

  add_foreign_key "addresses", "users"
  add_foreign_key "amounts", "accounts"
  add_foreign_key "amounts", "entries"
  add_foreign_key "program_subscriptions", "programs"
end
