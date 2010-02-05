class Role < ActiveRecord::Base
  belongs_to :game
  has_many :placed_orders, :class_name => 'Order', :foreign_key => 'sender_id'
  has_many :inbox_orders, :class_name => 'Order', :foreign_key => 'inbox_id'
  has_many :received_orders, :class_name => 'Order', :foreign_key => 'receiver_id', :order => 'at_week'
  
  has_many :outgoing_shipments, :class_name => 'Order', :foreign_key => 'shipper_id'
  has_many :logistics, :class_name => 'Order', :foreign_key => 'logistics_id'
  has_many :incoming_shipments, :class_name => 'Order', :foreign_key => 'shipment_receiver_id', :order => 'at_week'
  
  has_one :downstream, :class_name => 'Role', :foreign_key => 'upstream_id'
  belongs_to :upstream, :class_name => 'Role', :foreign_key => 'upstream_id'
  
  def place_order(amount)
    return if order_placed?
    update_attributes(:order_placed => true)
    order = placed_orders.create!(:amount => amount, :at_week => current_week)
    upstream.inbox_orders << order
    game.order_placed()
  end
  
  def update_status
    update_attributes(:order_placed => false)
    handle_logistics
    handle_inbox_orders
  end
  
  def information_delay_arrived?
    return (current_week - 1) >= information_delay
  end
  
  def shipping_delay_arrived?
    return (current_week - 1) >= shipping_delay + upstream.information_delay
  end
  
  def ship(order_amount)
    requested_amount = order_amount + backorder
    shipment_amount = inventory < requested_amount ? inventory : requested_amount
    new_backorder = inventory < requested_amount ? requested_amount - inventory : 0
    order = outgoing_shipments.create!(:amount => shipment_amount, :at_week => current_week)
    update_attributes(:inventory => inventory - shipment_amount, :backorder => new_backorder)
    downstream.logistics << order
  end
  
  private
  def handle_logistics
    logistics.clone.each{ |order|
      handle_incoming_shipment(order) if order.at_week == current_week - shipping_delay
    }
  end
  
  def handle_incoming_shipment order
    incoming_shipments.create!(:amount => order.amount, :at_week => current_week, :shipper_id => order.shipper_id)
    update_attributes(:inventory => inventory + order.amount)
    logistics.delete(order)
  end
  
  def handle_inbox_orders
    inbox_orders.clone.each{ |order|
      handle_received_order(order) if order.at_week == current_week - information_delay
    }
  end
  
  def handle_received_order order
    order.update_attributes(:at_week => current_week)
    received_orders.create!(:amount => order.amount, :at_week => current_week, :sender_id => order.sender_id)
    inbox_orders.delete(order)
    
    ship(order.amount)
  end
  
  def current_week
    game.current_week
  end
end
