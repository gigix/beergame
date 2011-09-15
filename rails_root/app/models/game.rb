class Game < ActiveRecord::Base
  MAX_INVENTORY = 1000000
  has_many :roles
  validates_presence_of :name
  
  def self.create_with_roles(name, role_names)
    game = create!(:name => name, :current_week => 1, :inventory_cost => 0.5, :backorder_cost => 1, :max_weeks => 30)
    Game.create_roles game, role_names
    Game.prepare_for_the_first_week game
  end
  
  def order_placed()
    return if gameover?
    pass_week if order_placing_finished? 
  end
  
  def gameover?
    current_week >= max_weeks
  end
  
  private
  def self.create_roles game,role_names
    last_role = game.roles.create!(:name => '顾客', :english_name => 'consumer')
    role_names.push({'工厂' => 'brewery'}).each do |role_name_hash| 
      puts role_name_hash
      upper_role = game.roles.create!(:name => role_name_hash.keys[0], :english_name => role_name_hash.values[0], :playable => true, :information_delay => 2, :shipping_delay => 2, :inventory => 12)
      last_role.update_attributes(:upstream => upper_role)
      last_role = upper_role
    end
    
    game.roles[game.roles.length-2].update_attributes(:information_delay => 1)
    game.roles.last.update_attributes(:playable => false, :shipping_delay => 1, :inventory => Game::MAX_INVENTORY)
  end
  
  def self.prepare_for_the_first_week game
    game.roles[1..game.roles.length-1].each{ |role|
      role.received_orders.create!(:amount => 4, :at_week => 1)
      role.received_shipments.create!(:amount => 4, :at_week => 1)
      role.update_status
    }
    game
  end
  
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

  def deliver_order_and_shipments
    customer_place_order
    
    roles[1..roles.length-1].each{ |role|
      role.deliver_placed_shipments
      role.deliver_placed_orders
    }
  end
  
  def place_order_and_shipments_during_delay_time
    place_shipments_during_upstream_shipping_delay
    place_order_during_downstream_information_delay
  end
  
  def customer_place_order
    roles[1].received_orders.create!(:amount => 8, :at_week => current_week)
  end
  
  def place_shipments_during_upstream_shipping_delay
    roles[1..roles.length-2].each{ |role|
      unless role.upstream.shipping_delay_arrived?
        role.received_shipments.create!(:amount => 4, :at_week => current_week)
      end
    }
  end
  
  def place_order_during_downstream_information_delay
    roles[2..roles.length-1].each{ |role|
      unless role.downstream.information_delay_arrived?
        role.received_orders.create!(:amount => 4, :at_week => current_week)
      end
    }
  end
end
