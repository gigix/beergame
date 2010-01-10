class Role < ActiveRecord::Base
  belongs_to :game
  has_many :placed_orders, :class_name => "Order", :foreign_key => 'role_id'
  
  has_one :downstream, :class_name => 'Role', :foreign_key => 'upstream_id'
  belongs_to :upstream, :class_name => 'Role', :foreign_key => 'upstream_id'
  
  
  def place_order(amount)
    order = placed_orders.create!(:amount => amount)
  end
  
end
