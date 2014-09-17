class AddSourceNameToRecipes < ActiveRecord::Migration
  def change
    add_column :recipes, :source_name, :string
  end
end
