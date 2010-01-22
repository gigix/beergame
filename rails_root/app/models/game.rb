class Game < ActiveRecord::Base
  has_many :roles
  attr_accessor :roles_placed_order
  
  def self.create_with_roles(name, role_names)
    game = create!(:name => name, :current_week => 1, :information_delay => 2, :shipping_delay => 2)
    
    last_role = game.roles.create!(:name => 'consumer')
    role_names.push('brewery').each do |role_name| 
      upper_role = game.roles.create!(:name => role_name, :playable => true)
      last_role.update_attributes(:upstream => upper_role)
      last_role = upper_role
    end
    
    last_role.update_attributes(:playable => false)
    game.roles.first.place_order 4
    game
  end
  
  def order_placed()
    pass_week if order_placing_finished? 
  end
  
  private
  def order_placing_finished?
    roles[0..roles.length-2].each { |role|
      return false if not role.order_placed? 
    }
    return true
  end
  
  def pass_week
    update_attributes(:current_week => current_week+1)
    roles.each{ |role|
      role.update_status
    }
    roles.first.place_order 8
  end
end
