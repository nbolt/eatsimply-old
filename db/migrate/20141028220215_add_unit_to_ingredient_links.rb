class AddUnitToIngredientLinks < ActiveRecord::Migration
  def change
    add_column :ingredient_links, :unit_id, :integer
  end
end
