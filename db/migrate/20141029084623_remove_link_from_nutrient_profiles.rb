class RemoveLinkFromNutrientProfiles < ActiveRecord::Migration
  def change
    remove_column :nutrient_profiles, :ingredients_units_id, :integer
  end
end
