class AddUnitToServings < ActiveRecord::Migration
  def change
    add_column :servings, :unit_id, :integer
  end
end
