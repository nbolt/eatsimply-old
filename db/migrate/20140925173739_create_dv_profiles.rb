class CreateDvProfiles < ActiveRecord::Migration
  def change
    create_table :dv_profiles do |t|

      t.timestamps
    end
  end
end
