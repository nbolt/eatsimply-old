class AddIngredientIdToServings < ActiveRecord::Migration
  def change
    add_column :servings, :ingredient_id, :integer
  end
end
