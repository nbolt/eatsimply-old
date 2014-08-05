class Recipe < ActiveRecord::Base
  has_many :ingredients
  has_many :servings, dependent: :destroy
  has_many :recipe_images, dependent: :destroy
  has_and_belongs_to_many :courses
  has_and_belongs_to_many :cuisines

  def as_json(options = {})
    super options.merge(include: [:recipe_images])
  end
end
