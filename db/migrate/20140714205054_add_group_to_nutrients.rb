class AddGroupToNutrients < ActiveRecord::Migration
  def change
    add_column :nutrients, :group, :string
  end
end
