class Game < ActiveRecord::Base
  MAX_INVENTORY = 1000000
  has_many :roles
  attr_accessor :roles_placed_order
  
  def self.create_with_roles(name, role_names)
    game = create!(:name => name, :current_week => 1)
    
    last_role = game.roles.create!(:name => '顾客')
    role_names.push('工厂').each do |role_name| 
      upper_role = game.roles.create!(:name => role_name, :playable => true, :information_delay => 2, :shipping_delay => 2, :inventory => 12)
      last_role.update_attributes(:upstream => upper_role)
      last_role = upper_role
    end
    
    game.roles[game.roles.length-2].update_attributes(:information_delay => 1)
    game.roles.last.update_attributes(:playable => false, :shipping_delay => 1, :inventory => Game::MAX_INVENTORY)
    
    game.roles.first.update_status
    game.roles[1..game.roles.length-1].each{ |role|
      role.received_orders.create!(:amount => 4, :at_week => 1)
      role.received_shipments.create!(:amount => 4, :at_week => 1)
      role.update_status
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
    place_order_and_shipments_during_delay_time
    deliver_order_and_shipments
    roles[1..roles.length-1].each{ |role|
      role.update_status
    }
  end

  private 
  def deliver_order_and_shipments
    customer_place_order
    
    roles[1..roles.length-1].each{ |role|
      role.deliver_placed_shipments
      role.deliver_placed_orders
    }
  end
  
  def place_order_and_shipments_during_delay_time
    roles[1].received_shipments.create!(:amount => 4, :at_week => current_week) unless roles[1].upstream.shipping_delay_arrived?
    
    roles[2..roles.length-2].each{ |role|
      unless role.downstream.information_delay_arrived?
        role.received_orders.create!(:amount => 4, :at_week => current_week)
      end
      unless role.upstream.shipping_delay_arrived?
        role.received_shipments.create!(:amount => 4, :at_week => current_week)
      end
    }
    
    roles.last.received_orders.create!(:amount => 4, :at_week => current_week) unless roles.last.downstream.information_delay_arrived?
  end
  
  def customer_place_order
    roles[1].received_orders.create!(:amount => 8, :at_week => current_week)
  end

end
