class CreateIngredientLink < ActiveRecord::Migration
  def change
    create_table :ingredient_links do |t|
      t.integer :ingredient_id
      t.integer :recipe_id
      t.string :description
    end
  end
end
