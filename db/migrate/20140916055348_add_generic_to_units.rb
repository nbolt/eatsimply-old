class AddGenericToUnits < ActiveRecord::Migration
  def change
    add_column :units, :generic, :boolean
  end
end
