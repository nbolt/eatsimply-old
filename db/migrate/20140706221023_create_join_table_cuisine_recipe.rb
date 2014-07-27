class CreateJoinTableCuisineRecipe < ActiveRecord::Migration
  def change
    create_join_table :cuisines, :recipes do |t|
      # t.index [:cuisine_id, :recipe_id]
      # t.index [:recipe_id, :cuisine_id]
    end
  end
end
