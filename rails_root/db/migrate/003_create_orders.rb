class CreateOrders < ActiveRecord::Migration
  def self.up
    create_table :orders do |t|
      t.integer :role_id
      t.integer :amount
      
      t.timestamps
    end
  end

  def self.down
    drop_table :orders
  end
end
