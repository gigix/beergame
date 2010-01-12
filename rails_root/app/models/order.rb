class Order < ActiveRecord::Base
  belongs_to :sender, :class_name => 'Role', :foreign_key => 'sender_id'
  belongs_to :inbox, :class_name => 'Role', :foreign_key => 'inbox_id'
end
