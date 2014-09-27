class CreateValueLinks < ActiveRecord::Migration
  def change
    create_table :value_links do |t|
      t.integer :recipe_id
      t.integer :dv_profile_id
      t.float :value

      t.timestamps
    end
  end
end
