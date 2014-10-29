class AddNutritionixFromIngredientsUnits < ActiveRecord::Migration
  def change
    add_column :ingredients_units, :nutri_id, :string
  end
end
