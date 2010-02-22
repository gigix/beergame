class AddCostsToGame < ActiveRecord::Migration
  def self.up
    add_column :games, :inventory_cost, :float
    add_column :games, :backorder_cost, :float
  end

  def self.down
    remove_column :games, :inventory_cost, :float
    remove_column :games, :backorder_cost, :float
  end
end