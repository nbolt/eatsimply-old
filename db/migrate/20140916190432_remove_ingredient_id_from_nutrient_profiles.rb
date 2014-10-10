class RemoveIngredientIdFromNutrientProfiles < ActiveRecord::Migration
  def change
    remove_column :nutrient_profiles, :ingredient_id, :integer
  end
end
