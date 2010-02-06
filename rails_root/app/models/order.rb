class Order < ActiveRecord::Base
  belongs_to :sender, :class_name => 'Role', :foreign_key => 'sender_id'
  belongs_to :receiver, :class_name => 'Role', :foreign_key => 'receiver_id'
  
  belongs_to :shipper, :class_name => 'Role', :foreign_key => 'shipper_id'
  belongs_to :shipment_receiver, :class_name => 'Role', :foreign_key => 'incoming_shipment_id'
  validates_presence_of :amount
  
  def sent_from
    sent_role = Role.find(:all, :conditions =>{:id => outbox_id}).first
    sent_role.nil?? "game" : sent_role.name
  end
  
  def shipped_from
    shipped_role = Role.find(:all, :conditions =>{:id => ship_outbox_id}).first
    shipped_role.nil?? "game" : shipped_role.name
  end
end
