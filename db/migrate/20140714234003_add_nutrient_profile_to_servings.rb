class AddNutrientProfileToServings < ActiveRecord::Migration
  def change
    add_column :servings, :nutrient_profile_id, :integer
  end
end
