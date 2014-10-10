class CreateNutrientProfiles < ActiveRecord::Migration
  def change
    create_table :nutrient_profiles do |t|
      t.string :name
      t.integer :ingredient_id

      t.timestamps
    end
  end
end
