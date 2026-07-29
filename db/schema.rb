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

ActiveRecord::Schema[8.0].define(version: 2026_07_29_164740) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "entries", force: :cascade do |t|
    t.integer "pool_id"
    t.integer "user_id"
    t.string "name"
    t.boolean "survivorStatusIn", default: true
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["pool_id"], name: "index_entries_on_pool_id"
    t.index ["user_id"], name: "index_entries_on_user_id"
  end

  create_table "game_picks", force: :cascade do |t|
    t.bigint "pick_id"
    t.integer "game_pick_id"
    t.integer "chosenTeamIndex"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["pick_id"], name: "index_game_picks_on_pick_id"
  end

  create_table "games", force: :cascade do |t|
    t.integer "homeTeamIndex"
    t.integer "awayTeamIndex"
    t.integer "spread"
    t.integer "week_id"
    t.integer "homeTeamScore", default: 0
    t.integer "awayTeamScore", default: 0
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.datetime "game_date", precision: nil
    t.string "network"
    t.boolean "final", default: false
  end

  create_table "picks", force: :cascade do |t|
    t.integer "week_id"
    t.integer "entry_id"
    t.integer "week_number"
    t.integer "totalScore", default: 0
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["entry_id"], name: "index_picks_on_entry_id"
  end

  create_table "pool_memberships", force: :cascade do |t|
    t.integer "user_id"
    t.integer "pool_id"
    t.boolean "owner", default: false, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "pools", force: :cascade do |t|
    t.string "name"
    t.bigint "season_id"
    t.integer "pool_type", default: 2
    t.integer "starting_week", default: 1
    t.boolean "allowMulti", default: false
    t.boolean "isPublic", default: true
    t.string "password_digest"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "pool_done", default: false
    t.index ["season_id"], name: "index_pools_on_season_id"
  end

  create_table "seasons", force: :cascade do |t|
    t.string "year"
    t.integer "state"
    t.boolean "nfl_league"
    t.integer "number_of_weeks"
    t.integer "current_week"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "teams", force: :cascade do |t|
    t.string "name"
    t.boolean "nfl"
    t.string "imagePath"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "user_name"
    t.string "email"
    t.boolean "admin", default: false
    t.boolean "supervisor", default: false
    t.string "password_digest"
    t.boolean "activated", default: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.datetime "activated_at", precision: nil
    t.string "phone"
    t.integer "contact", default: 1
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "weeks", force: :cascade do |t|
    t.bigint "season_id"
    t.integer "state"
    t.integer "week_number"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["season_id"], name: "index_weeks_on_season_id"
  end

  add_foreign_key "sessions", "users"
end
