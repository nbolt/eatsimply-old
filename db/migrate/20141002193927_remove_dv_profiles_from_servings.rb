class RemoveDvProfilesFromServings < ActiveRecord::Migration
  def change
    remove_column :servings, :dv_profile_id, :integer
  end
end
