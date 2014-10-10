class DropDvProfile < ActiveRecord::Migration
  def change
    drop_table :dv_profiles
  end
end
