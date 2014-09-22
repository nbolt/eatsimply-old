class AddDvUnitToNutrients < ActiveRecord::Migration
  def change
    add_column :nutrients, :dv_unit, :string
  end
end
