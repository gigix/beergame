class Game < ActiveRecord::Base
  has_many :roles
  attr_accessor :roles_placed_order
  
  def self.create_with_roles(name, role_names)
    game = create!(:name => name, :current_week => 1)
    
    last_role = game.roles.create!(:name => 'consumer')
    role_names.push('brewery').each do |role_name| 
      upper_role = game.roles.create!(:name => role_name, :playable => true, :information_delay => 2, :shipping_delay => 2, :inventory => 12)
      last_role.update_attributes(:upstream => upper_role)
      last_role = upper_role
    end
    
    last_role.update_attributes(:playable => false, :information_delay => 1, :shipping_delay => 1)

    game.roles[1..game.roles.length-1].each{ |role|
      order = role.received_orders.create!(:amount => 4, :at_week => 1)
    }
    game
  end
  
  def order_placed()
    pass_week if order_placing_finished? 
  end
  
  private
  def order_placing_finished?
    roles[1..roles.length-2].each { |role|
      return false if not role.order_placed? 
    }
    return true
  end
  
  def pass_week
    update_attributes(:current_week => current_week+1)
    
    roles[1].received_orders.create!(:amount => 8, :at_week => current_week)
    roles[1].update_status
    roles[2..roles.length-1].each{ |role|
      role.received_orders.create!(:amount => 4, :at_week => current_week) unless role.information_delay_arrived?
      role.update_status
    }
  end

end
