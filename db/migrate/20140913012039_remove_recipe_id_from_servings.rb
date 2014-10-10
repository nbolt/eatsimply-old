class RemoveRecipeIdFromServings < ActiveRecord::Migration
  def change
    remove_column :servings, :recipe_id, :integer
  end
end
