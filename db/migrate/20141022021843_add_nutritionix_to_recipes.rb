class AddNutritionixToRecipes < ActiveRecord::Migration
  def change
    add_column :recipes, :nutritionix_id, :string
    add_column :recipes, :public, :boolean
  end
end
