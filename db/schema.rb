# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_06_28_214709) do

  create_table "feeds", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "name"
    t.string "query"
    t.index ["user_id"], name: "index_feeds_on_user_id"
  end

  create_table "items", force: :cascade do |t|
    t.string "feedlyID"
    t.string "title"
    t.string "summaryContent"
    t.string "canonicalUrl"
    t.string "visualUrl"
    t.string "originUrl"
    t.string "originTitle"
    t.integer "engagement"
    t.float "engagementRate"
    t.integer "published"
  end

  create_table "items_tags", id: false, force: :cascade do |t|
    t.integer "tag_id", null: false
    t.integer "item_id", null: false
    t.index ["item_id"], name: "index_items_tags_on_item_id"
    t.index ["tag_id"], name: "index_items_tags_on_tag_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "google_token"
    t.string "google_refresh_token"
  end

  add_foreign_key "feeds", "users"
end
