class Role < ActiveRecord::Base
  belongs_to :game
  has_many :placed_orders, :class_name => 'Order', :foreign_key => 'sender_id'
  has_many :received_orders, :class_name => 'Order', :foreign_key => 'receiver_id'
  
  has_many :placed_shipments, :class_name => 'Order', :foreign_key => 'shipper_id'
  has_many :received_shipments, :class_name => 'Order', :foreign_key => 'shipment_receiver_id'
  
  has_one :downstream, :class_name => 'Role', :foreign_key => 'upstream_id'
  belongs_to :upstream, :class_name => 'Role', :foreign_key => 'upstream_id'
  
  has_many :inventory_histories, :class_name => 'InventoryHistory', :foreign_key => 'role_id'
  has_many :cost_histories, :class_name => 'CostHistory', :foreign_key => 'role_id'
  
  def place_order(amount)
    return if order_placed?
    update_attributes(:order_placed => true)
    placed_orders.create!(:amount => amount, :at_week => current_week)
    game.order_placed()
  end
  
  def update_status
    update_attributes(:order_placed => false)
    handle_received_orders
    inventory_histories.create!(:amount => inventory, :at_week => current_week)
    cost_histories.create!(:amount => cal_new_cost + current_cost, :at_week => current_week)
  end
  
  def information_delay_arrived?
    return (current_week - 1) >= information_delay
  end
  
  def shipping_delay_arrived?
    return (current_week - 1) >= shipping_delay
  end
  
  def deliver_placed_shipments
    placed_shipments.each{ |shipment|
      deliver_shipment shipment if shipment.at_week == current_week - shipping_delay
    }
  end
  
  def deliver_placed_orders
    placed_orders.each{ |order|
      deliver_order order if order.at_week == current_week - information_delay
    }
  end
  
  def backorder
    has_inventory?? 0 : inventory.abs
  end
  
  def has_inventory?
    inventory >= 0
  end
  
  private
  def current_cost
    return 0 if cost_histories.empty?
    cost_histories.last.amount
  end
  
  def cal_new_cost
    has_inventory?? inventory * game.inventory_cost : inventory.abs * game.backorder_cost
  end

  def handle_received_orders
    return if received_orders.empty?
    order = received_orders.last
    ship(order.amount)
  end
  
  def currently_received_shipment
    return if received_shipments.empty?
    shipment = received_shipments.last.amount
  end

  def deliver_order order
    upstream.received_orders.create!(:amount => order.amount, :at_week => current_week)
  end
  
  def deliver_shipment shipment
    downstream.received_shipments.create!(:amount => shipment.amount, :at_week => current_week)
  end
  
  def ship(order_amount)
    requested_amount = order_amount + backorder
    tmp_inventory = has_inventory?? inventory + currently_received_shipment : currently_received_shipment
    shipment_amount = tmp_inventory < requested_amount ? tmp_inventory : requested_amount
    order = placed_shipments.create!(:amount => shipment_amount, :at_week => current_week)
    update_attributes(:inventory => tmp_inventory - requested_amount)
  end

  def current_week
    game.current_week
  end
end
