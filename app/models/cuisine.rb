class Cuisine < ActiveRecord::Base
  include PgSearch
  pg_search_scope :search, against: :name, using: { tsearch: { prefix: true } }
end
