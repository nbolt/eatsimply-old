class NutrientProfile < ActiveRecord::Base
  include PgSearch
  pg_search_scope :search, against: :name
  
  belongs_to :ingredient
  belongs_to :recipe
  has_many :servings, dependent: :destroy
end
