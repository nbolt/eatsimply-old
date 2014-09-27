class DvProfile < ActiveRecord::Base
	has_many :servings, dependent: :destroy
	has_many :nutrients, through: :servings
end
