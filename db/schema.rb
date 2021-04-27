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

ActiveRecord::Schema.define(version: 2021_02_01_184644) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "games", force: :cascade do |t|
    t.bigint "week_id"
    t.integer "homeTeamIndex"
    t.integer "awayTeamIndex"
    t.integer "spread"
    t.integer "homeTeamScore"
    t.integer "awayTeamScore"
    t.datetime "game_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["week_id"], name: "index_games_on_week_id"
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

  create_table "weeks", force: :cascade do |t|
    t.integer "state"
    t.integer "week_number"
    t.bigint "season_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["season_id"], name: "index_weeks_on_season_id"
  end

  add_foreign_key "games", "weeks"
  add_foreign_key "weeks", "seasons"
end
