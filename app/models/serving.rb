class Serving < ActiveRecord::Base
  belongs_to :recipe
  belongs_to :nutrient_profile
  belongs_to :nutrient
end
