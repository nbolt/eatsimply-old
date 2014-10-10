class AddYummlyAttrToDiets < ActiveRecord::Migration
  def change
    add_column :diets, :yummly_attr, :string
  end
end
