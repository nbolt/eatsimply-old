class RemoveNameFromNutrientProfiles < ActiveRecord::Migration
  def change
    remove_column :nutrient_profiles, :name, :string
  end
end
