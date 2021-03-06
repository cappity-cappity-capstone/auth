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

ActiveRecord::Schema.define(version: 20150211194640) do

  create_table "control_servers", force: :cascade do |t|
    t.string   "uuid",       null: false
    t.string   "ip",         null: false
    t.integer  "port",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "control_servers", ["uuid"], name: "index_control_servers_on_uuid", unique: true

  create_table "sessions", force: :cascade do |t|
    t.string   "key",        null: false
    t.datetime "expires_on", null: false
    t.integer  "user_id",    null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "sessions", ["user_id"], name: "index_sessions_on_user_id"

  create_table "users", force: :cascade do |t|
    t.string   "name",              null: false
    t.string   "email",             null: false
    t.string   "password_salt",     null: false
    t.string   "password_hash",     null: false
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.integer  "control_server_id"
  end

  add_index "users", ["control_server_id"], name: "index_users_on_control_server_id"
  add_index "users", ["email"], name: "index_users_on_email", unique: true

end
