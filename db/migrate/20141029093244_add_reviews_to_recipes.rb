class AddReviewsToRecipes < ActiveRecord::Migration
  def change
    add_column :recipes, :review, :boolean, default: true
  end
end
