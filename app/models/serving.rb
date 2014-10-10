class Serving < ActiveRecord::Base
  belongs_to :ingredient
  belongs_to :nutrient_profile
  belongs_to :nutrient
  belongs_to :unit
end
