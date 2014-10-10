class Ingredient < ActiveRecord::Base
  include PgSearch
  pg_search_scope :search, against: :name, using: { tsearch: { any_word: true, prefix: true } }

  has_many :ingredient_links, dependent: :destroy
  has_many :recipes, through: :ingredient_links
  has_many :units, through: :ingredients_units, dependent: :destroy, autosave: true
  has_many :ingredients_units, class_name: 'IngredientsUnits'
end
