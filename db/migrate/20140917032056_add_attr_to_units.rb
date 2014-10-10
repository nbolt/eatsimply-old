class AddAttrToUnits < ActiveRecord::Migration
  def change
    add_column :units, :abbr_no_period, :string
  end
end
