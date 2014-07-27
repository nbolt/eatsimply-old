class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.json :recipe_cache

      t.timestamps
    end
  end
end
