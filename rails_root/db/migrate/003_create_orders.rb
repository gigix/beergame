class CreateOrders < ActiveRecord::Migration
  def self.up
    create_table :orders do |t|
      t.integer :sender_id
      t.integer :outbox_id
      t.integer :receiver_id
      t.integer :shipper_id
      t.integer :ship_outbox_id
      t.integer :shipment_receiver_id
      t.integer :amount
      t.integer :at_week
      
      t.timestamps
    end
  end

  def self.down
    drop_table :orders
  end
end
