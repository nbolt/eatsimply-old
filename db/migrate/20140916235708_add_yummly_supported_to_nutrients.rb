class AddYummlySupportedToNutrients < ActiveRecord::Migration
  def change
    add_column :nutrients, :yummly_supported, :boolean
  end
end
