class IngredientLink < ActiveRecord::Base
  belongs_to :ingredient
  belongs_to :recipe
  belongs_to :unit
end
