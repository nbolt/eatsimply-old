class RemovePublicFromRecipes < ActiveRecord::Migration
  def change
    remove_column :recipes, :public, :boolean
  end
end
