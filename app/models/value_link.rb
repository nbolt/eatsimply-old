class ValueLink < ActiveRecord::Base
	belongs_to :recipe
	belongs_to :dv_profile
end
