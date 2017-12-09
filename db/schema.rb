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

ActiveRecord::Schema.define(version: 20191203031017) do

  create_table "appointments", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "handler_id"
    t.string "handler_type"
    t.integer "user_id"
    t.integer "service_id"
    t.string "book_time"
    t.text "book_notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "state", default: false, null: false
  end

  create_table "hair_dressers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.boolean "is_independent"
    t.string "longitud"
    t.string "latitud"
    t.text "description"
    t.boolean "online_payment"
    t.decimal "rating", precision: 2, scale: 2
    t.boolean "state"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "time_table", limit: 4294967295
  end

  create_table "pictures", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image_file_name"
    t.string "image_content_type"
    t.integer "image_file_size"
    t.datetime "image_updated_at"
    t.integer "owner_id"
    t.integer "store_showcase_id"
    t.string "store_showcase_type", limit: 45
    t.string "owner_type", limit: 45
  end

  create_table "services", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.text "description"
    t.decimal "price", precision: 10, scale: 2
    t.string "duration"
    t.integer "watcher_id"
    t.string "watcher_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "stores", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "owner_id"
    t.string "name"
    t.float "longitude", limit: 24
    t.float "latitude", limit: 24
    t.string "zip_code"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "ratings", precision: 2, scale: 2
    t.string "owner_type", limit: 45
    t.text "time_table", limit: 4294967295
    t.string "place_id"
  end

  create_table "stores_users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "store_id"
    t.integer "user_id"
    t.boolean "confirmed", default: false
    t.string "confirmation_class"
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "age"
    t.string "sex"
    t.string "zip_code"
    t.string "profile_pic"
    t.string "phone_number"
    t.string "email"
    t.string "stripe_id"
    t.integer "id_hairdresser"
    t.string "is_shop_owner"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "uuid"
    t.string "provider"
    t.string "last_location"
  end

end
