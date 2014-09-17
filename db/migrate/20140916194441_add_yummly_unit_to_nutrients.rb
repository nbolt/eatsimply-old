class AddYummlyUnitToNutrients < ActiveRecord::Migration
  def change
    add_column :nutrients, :yummly_unit, :string
  end
end
