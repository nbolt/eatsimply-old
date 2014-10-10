class AddDvProfileToServings < ActiveRecord::Migration
  def change
    add_column :servings, :dv_profile_id, :integer
  end
end
