class RemoveYummlyAttrFromNutrients < ActiveRecord::Migration
  def change
    remove_column :nutrients, :yummly_attr, :string
  end
end
