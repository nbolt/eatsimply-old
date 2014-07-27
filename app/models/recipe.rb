class Recipe < ActiveRecord::Base
  has_many :ingredients
  has_many :servings, dependent: :destroy
  has_many :images, dependent: :destroy
  has_and_belongs_to_many :courses
  has_and_belongs_to_many :cuisines
end
