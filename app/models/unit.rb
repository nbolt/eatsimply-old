class Unit < ActiveRecord::Base
	include PgSearch
  pg_search_scope :search, against: :name, using: { tsearch: { prefix: true } }
	
	has_many :servings, dependent: :destroy
end
