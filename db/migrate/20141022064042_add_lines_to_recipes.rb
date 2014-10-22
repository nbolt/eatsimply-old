class AddLinesToRecipes < ActiveRecord::Migration
  def change
    add_column :recipes, :ingredient_lines, :text
  end
end
