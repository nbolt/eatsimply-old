class AddYummlyAttrToCuisines < ActiveRecord::Migration
  def change
    add_column :cuisines, :yummly_attr, :string
  end
end
