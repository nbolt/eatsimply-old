class AddRecipesToValueLinks < ActiveRecord::Migration
  def change
    add_column :value_links, :recipe1_id, :integer
    add_column :value_links, :recipe2_id, :integer
  end
end
