class RemoveIngredientIdFromServings < ActiveRecord::Migration
  def change
    remove_column :servings, :ingredient_id, :integer
  end
end
