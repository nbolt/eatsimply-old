class Ingredient < ActiveRecord::Base
  include PgSearch
  pg_search_scope :search, against: :name, using: { tsearch: { any_word: true, prefix: true } }

  has_many :recipes, through: :ingredient_link
  has_many :servings, dependent: :destroy
  belongs_to :food
end
