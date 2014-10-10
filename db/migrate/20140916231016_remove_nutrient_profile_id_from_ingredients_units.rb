class RemoveNutrientProfileIdFromIngredientsUnits < ActiveRecord::Migration
  def change
    remove_column :ingredients_units, :nutrient_profile_id, :integer
  end
end
