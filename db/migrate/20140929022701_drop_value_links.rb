class DropValueLinks < ActiveRecord::Migration
  def change
    drop_table :value_links
  end
end
