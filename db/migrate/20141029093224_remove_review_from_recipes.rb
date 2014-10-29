class RemoveReviewFromRecipes < ActiveRecord::Migration
  def change
    remove_column :recipes, :review, :boolean
  end
end
