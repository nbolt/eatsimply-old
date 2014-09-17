class AddYummlyFieldToNutrients < ActiveRecord::Migration
  def change
    add_column :nutrients, :yummly_field, :string
  end
end
