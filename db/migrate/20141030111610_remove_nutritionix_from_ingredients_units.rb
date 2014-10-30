class RemoveNutritionixFromIngredientsUnits < ActiveRecord::Migration
  def change
    remove_column :ingredients_units, :nutri_id, :string
  end
end
