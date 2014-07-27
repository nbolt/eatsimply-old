class CreateNutrients < ActiveRecord::Migration
  def change
    create_table :nutrients do |t|
      t.string :name
      t.string :unit_name
      t.string :unit_description
      t.string :unit_plural
      t.string :unit_abbr
      t.string :unit_plural_abbr
      t.string :yummly_attr

      t.timestamps
    end
  end
end
