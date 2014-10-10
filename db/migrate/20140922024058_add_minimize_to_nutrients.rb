class AddMinimizeToNutrients < ActiveRecord::Migration
  def change
    add_column :nutrients, :minimize, :boolean
  end
end
