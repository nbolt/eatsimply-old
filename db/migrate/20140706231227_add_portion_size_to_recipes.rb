class AddPortionSizeToRecipes < ActiveRecord::Migration
  def change
    add_column :recipes, :portion_size, :integer
  end
end
