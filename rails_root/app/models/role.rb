class Role < ActiveRecord::Base
  belongs_to :game
  has_many :placed_orders, :class_name => 'Order', :foreign_key => 'sender_id'
  has_many :received_orders, :class_name => 'Order', :foreign_key => 'receiver_id'
  
  has_many :placed_shipments, :class_name => 'Order', :foreign_key => 'shipper_id'
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
  end
  
  def information_delay_arrived?
    return (current_week - 1) >= information_delay
  end
  
  def shipping_delay_arrived?
    return (current_week - 1) >= shipping_delay
  end
  
  def deliver_placed_shipments
    placed_shipments.each{ |shipment|
      deliver_shipement shipment if shipment.at_week == current_week - shipping_delay
    }
  end
  
  def deliver_placed_orders
    placed_orders.each{ |order|
      deliver_order order if order.at_week == current_week - information_delay
    }
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

  def deliver_order order
    upstream.received_orders.create!(:amount => order.amount, :at_week => current_week)
  end
  
  def deliver_shipement shipment
    downstream.received_shipments.create!(:amount => shipment.amount, :at_week => current_week)
  end
  
  def ship(order_amount)
    requested_amount = order_amount + backorder
    shipment_amount = inventory < requested_amount ? inventory : requested_amount
    new_backorder = inventory < requested_amount ? requested_amount - inventory : 0
    order = placed_shipments.create!(:amount => shipment_amount, :at_week => current_week)
    update_attributes(:inventory => inventory - shipment_amount, :backorder => new_backorder)
  end

  def current_week
    game.current_week
  end
end
