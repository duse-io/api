# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20150124174719) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "secret_parts", force: :cascade do |t|
    t.integer "index"
    t.integer "secret_id"
  end

  create_table "secrets", force: :cascade do |t|
    t.string "title"
    t.string "last_edited_by_id"
  end

  create_table "shares", force: :cascade do |t|
    t.text    "content"
    t.text    "signature"
    t.integer "user_id"
    t.integer "secret_part_id"
  end

  create_table "tokens", force: :cascade do |t|
    t.string   "token_hash"
    t.integer  "user_id"
    t.datetime "last_used_at"
  end

  add_index "tokens", ["token_hash"], name: "index_tokens_on_token_hash", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "username",           default: "", null: false
    t.string   "email",              default: "", null: false
    t.string   "password_digest",                 null: false
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.string   "type"
    t.text     "public_key"
    t.text     "private_key"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

end
