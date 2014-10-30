class AddDisplayAmountToIngredientLinks < ActiveRecord::Migration
  def change
    add_column :ingredient_links, :display_amount, :float
  end
end
