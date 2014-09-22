class AddUnitwiseMethodToNutrients < ActiveRecord::Migration
  def change
    add_column :nutrients, :unitwise_method, :string
  end
end
