class AddVegasToEmail < ActiveRecord::Migration
  def change
    add_column :emails, :vegas, :boolean, default: false
  end
end
