class Order < ActiveRecord::Base
  belongs_to :sender, :class_name => 'Role', :foreign_key => 'sender_id'
  belongs_to :inbox, :class_name => 'Role', :foreign_key => 'inbox_id'
  belongs_to :receiver, :class_name => 'Role', :foreign_key => 'receiver_id'
  
  belongs_to :shipper, :class_name => 'Role', :foreign_key => 'shipper_id'
  belongs_to :logistics, :class_name => 'Role', :foreign_key => 'logistics_id'
  belongs_to :shipment_receiver, :class_name => 'Role', :foreign_key => 'incoming_shipment_id'
  validates_presence_of :amount
end
