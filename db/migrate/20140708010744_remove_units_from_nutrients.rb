class RemoveUnitsFromNutrients < ActiveRecord::Migration
  def change
    remove_column :nutrients, :unit_name, :string
    remove_column :nutrients, :unit_description, :string
    remove_column :nutrients, :unit_plural, :string
    remove_column :nutrients, :unit_abbr, :string
    remove_column :nutrients, :unit_plural_abbr, :string
  end
end
