class AddMaxWeeksToGame < ActiveRecord::Migration
  def self.up
    add_column :games, :max_weeks, :integer
  end

  def self.down
    remove_column :games, :max_weeks, :integer
  end
end