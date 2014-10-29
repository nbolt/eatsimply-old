class AddYummlyToIngredientsUnits < ActiveRecord::Migration
  def change
    add_column :ingredients_units, :yummly_id, :string
  end
end
