class AddCacheRecipeToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :cache_recipe, :boolean
  end
end
