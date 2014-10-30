class AddNutritionixToIngredientLinks < ActiveRecord::Migration
  def change
    add_column :ingredient_links, :nutri_id, :string
  end
end
