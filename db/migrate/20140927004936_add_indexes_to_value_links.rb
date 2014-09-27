class AddIndexesToValueLinks < ActiveRecord::Migration
  def change
  	add_index :value_links, :recipe_id
  	add_index :value_links, :recipe1_id
  	add_index :value_links, :recipe2_id
  end
end
