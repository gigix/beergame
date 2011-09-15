class AddEnglishNameToRole < ActiveRecord::Migration
  def self.up
    add_column :roles, :english_name, :string
  end
  
  def self.down
    remove_column :roles, :english_name, :string
  end
end