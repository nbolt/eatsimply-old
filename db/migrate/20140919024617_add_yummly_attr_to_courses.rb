class AddYummlyAttrToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :yummly_attr, :string
  end
end
