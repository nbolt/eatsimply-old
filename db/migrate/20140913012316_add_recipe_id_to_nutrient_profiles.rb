class AddRecipeIdToNutrientProfiles < ActiveRecord::Migration
  def change
    add_column :nutrient_profiles, :recipe_id, :integer
  end
end
