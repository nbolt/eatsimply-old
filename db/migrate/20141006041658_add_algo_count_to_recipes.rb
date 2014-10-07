class AddAlgoCountToRecipes < ActiveRecord::Migration
  def change
    add_column :recipes, :algo_count, :integer, default: 0
  end
end
