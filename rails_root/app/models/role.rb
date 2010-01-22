class Role < ActiveRecord::Base
  belongs_to :game
  has_many :placed_orders, :class_name => 'Order', :foreign_key => 'sender_id'
  has_many :inbox_orders, :class_name => 'Order', :foreign_key => 'inbox_id'
  has_many :received_orders, :class_name => 'Order', :foreign_key => 'receiver_id'
  
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
    handle_inbox_orders
  end
  
  private
  def handle_inbox_orders
    inbox_orders.clone.each{ |order|
      handle_received_order(order) if order.at_week == current_week - information_delay
    }
  end
  
  def handle_received_order order
    order.update_attributes(:at_week => current_week)
    received_orders.push(order)
    inbox_orders.delete(order)
  end
  
  def current_week
    game.current_week
  end
end
