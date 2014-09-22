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

ActiveRecord::Schema.define(version: 20140922031407) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "authentications", force: true do |t|
    t.integer  "user_id",    null: false
    t.string   "provider",   null: false
    t.string   "uid",        null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "courses", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "yummly_attr"
  end

  create_table "courses_recipes", id: false, force: true do |t|
    t.integer "course_id", null: false
    t.integer "recipe_id", null: false
  end

  create_table "cuisines", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "yummly_attr"
  end

  create_table "cuisines_recipes", id: false, force: true do |t|
    t.integer "cuisine_id", null: false
    t.integer "recipe_id",  null: false
  end

  create_table "diets", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "yummly_attr"
  end

  create_table "diets_recipes", force: true do |t|
    t.integer "diet_id"
    t.integer "recipe_id"
  end

  create_table "emails", force: true do |t|
    t.string   "email"
    t.string   "zip"
    t.text     "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "vegas",      default: false
  end

  create_table "foods", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ingredient_links", force: true do |t|
    t.integer "ingredient_id"
    t.integer "recipe_id"
    t.string  "description"
  end

  create_table "ingredients", force: true do |t|
    t.string   "name"
    t.string   "group"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "food_id"
    t.boolean  "allergen_contains_eggs"
    t.boolean  "allergen_contains_tree_nuts"
    t.boolean  "allergen_contains_shellfish"
    t.boolean  "allergen_contains_peanuts"
    t.boolean  "allergen_contains_wheat"
    t.boolean  "allergen_contains_gluten"
    t.boolean  "allergen_contains_fish"
    t.boolean  "allergen_contains_soybeans"
    t.boolean  "allergen_contains_milk"
  end

  create_table "ingredients_units", force: true do |t|
    t.integer "unit_id"
    t.integer "ingredient_id"
  end

  create_table "nutrient_profiles", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "recipe_id"
    t.integer  "ingredients_units_id"
  end

  create_table "nutrients", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "group"
    t.string   "yummly_unit"
    t.string   "yummly_field"
    t.boolean  "yummly_supported"
    t.boolean  "nutri_supported"
    t.string   "attr"
    t.float    "daily_value"
    t.boolean  "minimize"
    t.string   "dv_unit"
    t.string   "unitwise_method"
  end

  create_table "recipe_images", force: true do |t|
    t.string   "image"
    t.integer  "recipe_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "recipes", force: true do |t|
    t.string   "name"
    t.string   "yummly_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "portion_size"
    t.integer  "time"
    t.string   "photo"
    t.string   "source"
    t.string   "source_name"
    t.string   "yield"
  end

  create_table "servings", force: true do |t|
    t.integer  "nutrient_id"
    t.float    "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "unit_id"
    t.integer  "nutrient_profile_id"
  end

  create_table "settings", force: true do |t|
    t.json     "recipe_cache"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "cache_recipe"
  end

  create_table "units", force: true do |t|
    t.string   "name"
    t.string   "abbr"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "generic"
    t.string   "abbr_no_period"
  end

  create_table "users", force: true do |t|
    t.string   "email",                        null: false
    t.string   "crypted_password",             null: false
    t.string   "salt",                         null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_me_token"
    t.datetime "remember_me_token_expires_at"
    t.datetime "last_login_at"
    t.datetime "last_logout_at"
    t.datetime "last_activity_at"
    t.string   "last_login_from_ip_address"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["last_logout_at", "last_activity_at"], name: "index_users_on_last_logout_at_and_last_activity_at", using: :btree
  add_index "users", ["remember_me_token"], name: "index_users_on_remember_me_token", using: :btree

end
