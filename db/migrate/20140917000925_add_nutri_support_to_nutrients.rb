class AddNutriSupportToNutrients < ActiveRecord::Migration
  def change
    add_column :nutrients, :nutri_supported, :boolean
  end
end
