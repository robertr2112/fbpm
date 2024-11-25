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

ActiveRecord::Schema.define(version: 2024_11_22_015539) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "entries", force: :cascade do |t|
    t.integer "pool_id"
    t.integer "user_id"
    t.string "name"
    t.boolean "survivorStatusIn", default: true
    t.integer "supTotalPoints", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pool_id"], name: "index_entries_on_pool_id"
    t.index ["user_id"], name: "index_entries_on_user_id"
  end

  create_table "game_picks", force: :cascade do |t|
    t.bigint "pick_id"
    t.integer "game_pick_id"
    t.integer "chosenTeamIndex"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pick_id"], name: "index_game_picks_on_pick_id"
  end

  create_table "games", force: :cascade do |t|
    t.integer "homeTeamIndex"
    t.integer "awayTeamIndex"
    t.integer "spread"
    t.integer "week_id"
    t.integer "homeTeamScore", default: 0
    t.integer "awayTeamScore", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "game_date"
    t.string "network"
    t.boolean "final", default: false
  end

  create_table "picks", force: :cascade do |t|
    t.integer "week_id"
    t.integer "entry_id"
    t.integer "week_number"
    t.integer "totalScore", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["entry_id"], name: "index_picks_on_entry_id"
  end

  create_table "pool_memberships", force: :cascade do |t|
    t.integer "user_id"
    t.integer "pool_id"
    t.boolean "owner", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "pools", force: :cascade do |t|
    t.string "name"
    t.bigint "season_id"
    t.integer "poolType"
    t.integer "starting_week", default: 1
    t.boolean "allowMulti", default: false
    t.boolean "isPublic", default: true
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "pool_done", default: false
    t.index ["season_id"], name: "index_pools_on_season_id"
  end

  create_table "seasons", force: :cascade do |t|
    t.string "year"
    t.integer "state"
    t.boolean "nfl_league"
    t.integer "number_of_weeks"
    t.integer "current_week"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "teams", force: :cascade do |t|
    t.string "name"
    t.boolean "nfl"
    t.string "imagePath"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "user_name"
    t.string "email"
    t.boolean "admin", default: false
    t.boolean "supervisor", default: false
    t.string "password_digest"
    t.string "remember_digest"
    t.string "password_reset_token"
    t.datetime "password_reset_sent_at"
    t.boolean "activated", default: false
    t.string "activation_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "activated_at"
    t.string "phone"
    t.integer "contact", default: 1
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["remember_digest"], name: "index_users_on_remember_digest"
  end

  create_table "weeks", force: :cascade do |t|
    t.bigint "season_id"
    t.integer "state"
    t.integer "week_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["season_id"], name: "index_weeks_on_season_id"
  end

end
