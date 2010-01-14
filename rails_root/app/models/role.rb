class Role < ActiveRecord::Base
  belongs_to :game
  has_many :placed_orders, :class_name => 'Order', :foreign_key => 'sender_id'
  has_many :inbox_orders, :class_name => 'Order', :foreign_key => 'inbox_id'
  
  has_one :downstream, :class_name => 'Role', :foreign_key => 'upstream_id'
  belongs_to :upstream, :class_name => 'Role', :foreign_key => 'upstream_id'
  
  def place_order(amount)
    return if @has_placed_order
    order = placed_orders.create!(:amount => amount)
    upstream.inbox_orders.push(order)
    game.order_placed(self)
    @has_placed_order = true
  end
  
  def update_status
    @has_placed_order = false
  end
end
