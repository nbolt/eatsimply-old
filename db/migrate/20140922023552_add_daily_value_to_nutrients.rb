class AddDailyValueToNutrients < ActiveRecord::Migration
  def change
    add_column :nutrients, :daily_value, :float
  end
end
