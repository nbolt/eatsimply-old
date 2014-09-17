class CreateIngredientsUnits < ActiveRecord::Migration
  def change
    create_table :ingredients_units do |t|
      t.integer :nutrient_profile_id
      t.integer :unit_id
      t.integer :ingredient_id
    end
  end
end
