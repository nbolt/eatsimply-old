class AddSourceToRecipe < ActiveRecord::Migration
  def change
    add_column :recipes, :source, :string
  end
end
