class CreateRoles < ActiveRecord::Migration
  def self.up
    create_table :roles do |t|
      t.integer :game_id
      t.integer :upstream_id
      t.string :name
      
      t.timestamps
    end
  end

  def self.down
    drop_table :roles
  end
end
