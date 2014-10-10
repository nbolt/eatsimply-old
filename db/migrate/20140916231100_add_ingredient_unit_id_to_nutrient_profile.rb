class AddIngredientUnitIdToNutrientProfile < ActiveRecord::Migration
  def change
    add_column :nutrient_profiles, :ingredients_units_id, :integer
  end
end
