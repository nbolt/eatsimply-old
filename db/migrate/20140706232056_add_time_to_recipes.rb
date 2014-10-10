class AddTimeToRecipes < ActiveRecord::Migration
  def change
    add_column :recipes, :time, :integer
  end
end
