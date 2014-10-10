class AddAllergensToIngredients < ActiveRecord::Migration
  def change
    add_column :ingredients, :allergen_contains_eggs, :boolean
    add_column :ingredients, :allergen_contains_tree_nuts, :boolean
    add_column :ingredients, :allergen_contains_shellfish, :boolean
    add_column :ingredients, :allergen_contains_peanuts, :boolean
    add_column :ingredients, :allergen_contains_wheat, :boolean
    add_column :ingredients, :allergen_contains_gluten, :boolean
    add_column :ingredients, :allergen_contains_fish, :boolean
    add_column :ingredients, :allergen_contains_soybeans, :boolean
    add_column :ingredients, :allergen_contains_milk, :boolean
  end
end
