class Ingredient < ActiveRecord::Base
  include PgSearch
  pg_search_scope :search, against: :name, using: { tsearch: { any_word: true, prefix: true } }

  has_many :servings, dependent: :destroy
  has_many :nutrient_profiles, through: :servings
  belongs_to :food
end
