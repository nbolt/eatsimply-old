class AddAmountToIngredientLinks < ActiveRecord::Migration
  def change
    add_column :ingredient_links, :amount, :float
  end
end
