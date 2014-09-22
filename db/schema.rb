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

  create_table "abbrev", primary_key: "ndb_no", force: true do |t|
    t.string  "shrt_desc",   limit: 60
    t.float   "water"
    t.integer "energ_kcal"
    t.float   "protein"
    t.float   "lipid_tot"
    t.float   "ash"
    t.float   "carbohydrt"
    t.float   "fiber_td"
    t.float   "sugar_tot",               default: 0.0
    t.integer "calcium"
    t.float   "iron"
    t.float   "magnesium",               default: 0.0
    t.integer "phosphorus"
    t.integer "potassium"
    t.integer "sodium"
    t.float   "zinc",                    default: 0.0
    t.float   "copper",                  default: 0.0
    t.float   "manganese",               default: 0.0
    t.float   "selenium",                default: 0.0
    t.float   "vit_c"
    t.float   "thiamin",                 default: 0.0
    t.float   "riboflavin",              default: 0.0
    t.float   "niacin",                  default: 0.0
    t.float   "panto_acid",              default: 0.0
    t.float   "vit_b6",                  default: 0.0
    t.float   "folate_tot",              default: 0.0
    t.float   "folic_acid",              default: 0.0
    t.float   "food_folate",             default: 0.0
    t.float   "folate_dfe",              default: 0.0
    t.float   "choline_tot",             default: 0.0
    t.float   "vit_b12",                 default: 0.0
    t.integer "vit_a_iu"
    t.float   "vit_a_rae",               default: 0.0
    t.float   "retinol",                 default: 0.0
    t.float   "alpha_carot",             default: 0.0
    t.float   "beta_carot",              default: 0.0
    t.float   "beta_crypt",              default: 0.0
    t.float   "lycopene",                default: 0.0
    t.float   "lut+zea",                 default: 0.0
    t.float   "vit_e",                   default: 0.0
    t.float   "vit_d_mcg",               default: 0.0
    t.float   "vivit_d_iu",              default: 0.0
    t.float   "vit_k",                   default: 0.0
    t.float   "fa_sat"
    t.float   "fa_mono",                 default: 0.0
    t.float   "fa_poly",                 default: 0.0
    t.integer "cholestrl"
    t.float   "gmwt_1"
    t.string  "gmwt_desc1",  limit: 120
    t.float   "gmwt_2",                  default: 0.0
    t.string  "gmwt_desc2",  limit: 120
    t.integer "refuse_pct"
  end

  add_index "abbrev", ["folic_acid"], name: "Abbrev_Folic_Acid_Index", using: :btree
  add_index "abbrev", ["panto_acid"], name: "Abbrev_Panto_Acid_Index", using: :btree

  create_table "active_nutrition_migrations", force: true do |t|
    t.integer  "sequence_no"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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

  create_table "data_src", id: false, force: true do |t|
    t.integer "datasrc_id"
    t.string  "authors"
    t.string  "title"
    t.string  "year",        limit: 4
    t.string  "journal",     limit: 135
    t.string  "vol_city",    limit: 16
    t.string  "issue_state", limit: 5
    t.string  "start_page",  limit: 5
    t.string  "end_page",    limit: 5
  end

  add_index "data_src", ["datasrc_id"], name: "DataSrc_ID_Index", using: :btree

  create_table "datsrcln", id: false, force: true do |t|
    t.integer "ndb_no",               null: false
    t.integer "nutr_no",              null: false
    t.string  "datasrc_id", limit: 6, null: false
  end

  add_index "datsrcln", ["ndb_no", "nutr_no", "datasrc_id"], name: "Datsrcln_NDB_No_Nutr_No_DataSrc_ID_Index", unique: true, using: :btree

  create_table "deriv_cd", id: false, force: true do |t|
    t.integer "deriv_cd"
    t.string  "deriv_desc", limit: 120
  end

  add_index "deriv_cd", ["deriv_cd"], name: "Deriv_CD_Deriv_CD_Index", using: :btree

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

  create_table "fd_group", primary_key: "fdgrp_cd", force: true do |t|
    t.string "fdgrp_desc", limit: 60
  end

  create_table "food_des", primary_key: "ndb_no", force: true do |t|
    t.string  "fdgrp_cd",    limit: 4
    t.string  "long_desc",   limit: 200
    t.string  "shrt_desc",   limit: 60
    t.string  "comname",     limit: 100
    t.string  "manufacname", limit: 65
    t.string  "survey",      limit: 1
    t.string  "ref_desc",    limit: 135
    t.integer "refuse"
    t.string  "sciname",     limit: 65
    t.float   "n_factor"
    t.float   "pro_factor"
    t.float   "fat_factor"
    t.float   "cho_factor"
  end

  create_table "footnote", id: false, force: true do |t|
    t.integer "ndb_no",                  null: false
    t.integer "footnt_no"
    t.string  "footnot_typ", limit: 1
    t.integer "nutr_no"
    t.string  "footnot_txt", limit: 200
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

  create_table "langdesc", id: false, force: true do |t|
    t.string "factor_code"
    t.string "description", limit: 250
  end

  add_index "langdesc", ["factor_code"], name: "LangDesc_Factor_Code_Index", using: :btree

  create_table "langual", id: false, force: true do |t|
    t.integer "ndb_no",                null: false
    t.string  "factor_code", limit: 6, null: false
  end

  add_index "langual", ["ndb_no", "factor_code"], name: "Langual_NDB_No_Factor_Code_Index", unique: true, using: :btree

  create_table "nut_data", id: false, force: true do |t|
    t.integer "ndb_no",                   null: false
    t.integer "nutr_no",                  null: false
    t.float   "nutr_val"
    t.integer "num_data_pts"
    t.float   "std_error"
    t.string  "src_cd",        limit: 2
    t.string  "deriv_cd",      limit: 4
    t.integer "ref_ndb_no"
    t.string  "add_nutr_mark", limit: 1
    t.integer "num_studies"
    t.float   "min"
    t.float   "max"
    t.float   "df"
    t.float   "low_eb"
    t.float   "up_eb"
    t.string  "stat_cmt",      limit: 10
    t.date    "addmod_date"
    t.string  "cc"
  end

  add_index "nut_data", ["ndb_no", "nutr_no"], name: "Nut_Data_NDB_No_Nutr_No_Index", unique: true, using: :btree
  add_index "nut_data", ["num_data_pts"], name: "Nut_Data_Num_Data_Pts_Index", using: :btree
  add_index "nut_data", ["num_studies"], name: "Num_Studies_Index", using: :btree

  create_table "nutr_def", primary_key: "nutr_no", force: true do |t|
    t.string "units",    limit: 7
    t.string "tagname",  limit: 20
    t.string "nutrdesc", limit: 60
    t.string "num_dec",  limit: 1
    t.float  "sr_order"
  end

  add_index "nutr_def", ["num_dec"], name: "Num_Dec_Index", using: :btree

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

  create_table "src_cd", primary_key: "src_cd", force: true do |t|
    t.string "srccd_desc", limit: 60
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

  create_table "weight", id: false, force: true do |t|
    t.integer "ndb_no",                  null: false
    t.integer "seq",                     null: false
    t.float   "amount"
    t.string  "msre_desc",    limit: 80
    t.float   "gm_wgt"
    t.integer "num_data_pts"
    t.float   "std_dev"
  end

  add_index "weight", ["ndb_no", "seq"], name: "Weight_NDB_No_Seq_Index", unique: true, using: :btree
  add_index "weight", ["num_data_pts"], name: "Weight_Num_Data_Pts_Index", using: :btree

end
