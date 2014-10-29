class RemoveFoodFromIngredients < ActiveRecord::Migration
  def change
    remove_column :ingredients, :food_id, :integer
  end
end
