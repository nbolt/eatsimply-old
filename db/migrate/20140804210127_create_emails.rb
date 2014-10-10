class CreateEmails < ActiveRecord::Migration
  def change
    create_table :emails do |t|
      t.string :email
      t.string :zip
      t.text :comments

      t.timestamps
    end
  end
end
