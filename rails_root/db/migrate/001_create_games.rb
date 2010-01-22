class CreateGames < ActiveRecord::Migration
  def self.up
    create_table :games do |t|
      t.string :name
      t.integer :current_week
      t.integer :information_delay
      t.integer :shipping_delay
      
      t.timestamps
    end
  end

  def self.down
    drop_table :games
  end
end
