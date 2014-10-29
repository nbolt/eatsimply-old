class NutrientProfile < ActiveRecord::Base
  include PgSearch
  pg_search_scope :search, against: :name
  
  belongs_to :recipe
  #belongs_to :ingredient_unit, foreign_key: 'ingredients_units', class_name: 'IngredientsUnits'
  has_many :servings, dependent: :destroy
  has_many :nutrients, through: :servings
end
