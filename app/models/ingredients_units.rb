class IngredientsUnits < ActiveRecord::Base
  belongs_to :unit
  belongs_to :ingredient
  has_one :nutrient_profile, dependent: :destroy
end
