class AddVeganizeToRecipes < ActiveRecord::Migration
  def change
    add_column :recipes, :veganize, :boolean
  end
end
