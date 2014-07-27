class NutrientProfile < ActiveRecord::Base
  include PgSearch
  pg_search_scope :search, against: :name
  
  belongs_to :ingredient
  has_many :servings, dependent: :destroy
end
