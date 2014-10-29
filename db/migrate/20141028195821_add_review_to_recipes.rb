class AddReviewToRecipes < ActiveRecord::Migration
  def change
    add_column :recipes, :review, :boolean, default: false
  end
end
