class Diet < ActiveRecord::Base
  include PgSearch
  pg_search_scope :search, against: :name, using: { tsearch: { prefix: true } }
  
  has_and_belongs_to_many :recipes
end
