class AddPrimeToNutrients < ActiveRecord::Migration
  def change
    add_column :nutrients, :prime, :boolean
  end
end
