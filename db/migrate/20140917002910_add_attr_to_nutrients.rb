class AddAttrToNutrients < ActiveRecord::Migration
  def change
    add_column :nutrients, :attr, :string
  end
end
