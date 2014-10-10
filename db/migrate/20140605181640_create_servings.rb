class CreateServings < ActiveRecord::Migration
  def change
    create_table :servings do |t|
      t.integer :recipe_id
      t.integer :ingredient_id
      t.integer :nutrient_id
      t.float :value

      t.timestamps
    end
  end
end
