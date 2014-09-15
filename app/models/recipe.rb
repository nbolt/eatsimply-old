class Recipe < ActiveRecord::Base
  has_one :nutrient_profile
  has_many :recipe_images, dependent: :destroy
  has_many :ingredients, through: :ingredient_link
  has_and_belongs_to_many :courses
  has_and_belongs_to_many :cuisines

  def as_json(options = {})
    super options.merge(include: [:recipe_images])
  end
end
