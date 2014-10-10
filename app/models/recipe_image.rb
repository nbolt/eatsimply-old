class RecipeImage < ActiveRecord::Base
  mount_uploader :image, RecipeImageUploader
end
