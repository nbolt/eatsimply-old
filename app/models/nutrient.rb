class Nutrient < ActiveRecord::Base
  has_many :servings, dependent: :destroy
  has_many :ingredients, through: :servings
  has_many :recipes, through: :servings
end
