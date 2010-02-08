class CreateInventoryHistories < ActiveRecord::Migration
  def self.up
    create_table :inventory_histories do |t|
      t.integer :role_id
      t.integer :amount
      t.integer :at_week 
      t.timestamps
    end
  end

  def self.down
    drop_table :inventory_histories
  end
end
