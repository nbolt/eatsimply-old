class Unit < ActiveRecord::Base
	include PgSearch
  pg_search_scope :search, against: :name, using: { tsearch: { prefix: true } }

  before_save do
    self.abbr_no_period = self.abbr.chomp('.') if self.abbr
  end
	
	has_many :servings, dependent: :destroy
  has_many :ingredients, through: :ingredients_units
  has_many :ingredients_units, class_name: 'IngredientsUnits'
end
