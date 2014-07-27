class AddFoodToIngredients < ActiveRecord::Migration
  def change
    add_column :ingredients, :food_id, :integer
  end
end
