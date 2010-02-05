class Role < ActiveRecord::Base
  belongs_to :game
  has_many :placed_orders, :class_name => 'Order', :foreign_key => 'sender_id'
  has_many :outbox_orders, :class_name => 'Order', :foreign_key => 'outbox_id'
  has_many :received_orders, :class_name => 'Order', :foreign_key => 'receiver_id'
  
  has_many :placed_shipments, :class_name => 'Order', :foreign_key => 'shipper_id'
  has_many :outbox_shipments, :class_name => 'Order', :foreign_key => 'ship_outbox_id'
  has_many :received_shipments, :class_name => 'Order', :foreign_key => 'shipment_receiver_id'
  
  has_one :downstream, :class_name => 'Role', :foreign_key => 'upstream_id'
  belongs_to :upstream, :class_name => 'Role', :foreign_key => 'upstream_id'
  
  def place_order(amount)
    return if order_placed?
    update_attributes(:order_placed => true)
    placed_orders.create!(:amount => amount, :at_week => current_week)
    game.order_placed()
  end
  
  def update_status
    update_attributes(:order_placed => false)
    handle_received_shipments
    handle_received_orders
    deliver_placed_shipments
    deliver_placed_orders
  end
  
  def information_delay_arrived?
    return (current_week - 1) >= information_delay
  end
  
  def shipping_delay_arrived?
    return (current_week - 1) >= shipping_delay
  end
  
  def ship(order_amount)
    requested_amount = order_amount + backorder
    shipment_amount = inventory < requested_amount ? inventory : requested_amount
    new_backorder = inventory < requested_amount ? requested_amount - inventory : 0
    order = placed_shipments.create!(:amount => shipment_amount, :at_week => current_week)
    update_attributes(:inventory => inventory - shipment_amount, :backorder => new_backorder)
  end
  
  private

  def handle_received_orders
    return if received_orders.empty?
    order = received_orders.last
    ship(order.amount)
  end
  
  def handle_received_shipments
    return if received_shipments.empty?
    shipment = received_shipments.last
    update_attributes(:inventory => inventory + shipment.amount)
  end
  
  def deliver_placed_orders
    placed_orders.each{ |order|
      outbox_orders << order if order.at_week == current_week - information_delay
    }
    deliver_outbox_orders
  end
  
  def deliver_outbox_orders
    return if outbox_orders.empty?
    order = outbox_orders.first
    upstream.received_orders.create!(:amount => order.amount, :at_week => current_week, :outbox_id => order.sender_id)
    outbox_orders.delete(order)
  end
  
  def deliver_placed_shipments
    placed_shipments.each{ |shipment|
      outbox_shipments << shipment if shipment.at_week == current_week - shipping_delay
    }
    deliver_outbox_shipments
  end
  
  def deliver_outbox_shipments
    return if outbox_shipments.empty?
    shipment = outbox_shipments.first
    downstream.received_shipments.create!(:amount => shipment.amount, :at_week => current_week, :ship_outbox_id => shipment.shipper_id)
    outbox_shipments.delete(shipment)
  end

  def current_week
    game.current_week
  end
end
