class RemoveYummlyFromIngredientsUnits < ActiveRecord::Migration
  def change
    remove_column :ingredients_units, :yummly_id, :string
  end
end
