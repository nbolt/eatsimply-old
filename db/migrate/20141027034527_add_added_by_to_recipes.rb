class AddAddedByToRecipes < ActiveRecord::Migration
  def change
    add_column :recipes, :added_by, :integer
  end
end
