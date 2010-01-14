class Game < ActiveRecord::Base
  has_many :roles
  attr_accessor :roles_placed_order
  
  def self.create_with_roles(name, role_names)
    game = create!(:name => name, :current_week => 1)
    
    last_role = game.roles.create!(:name => 'consumer')
    role_names.push('brewery').each do |role_name| 
      upper_role = game.roles.create!(:name => role_name, :playable => true)
      last_role.update_attributes(:upstream => upper_role)
      last_role = upper_role
    end
    
    last_role.update_attributes(:playable => false)
    game
  end
  
  def order_placed(role)
    @roles_placed_order = 0 if @roles_placed_order.nil?
    @roles_placed_order = @roles_placed_order + 1
    pass_week if order_placing_finished? 
  end
  
  private
  def order_placing_finished? 
    @roles_placed_order == (roles.size - 1)
  end

  def pass_week
    #current_week = current_week + 1
    next_week = current_week + 1
    update_attributes(:current_week => next_week)
    @roles_placed_order = 0
    consumer_place_order 4
  end
  
  def consumer_place_order amount
    #roles.first.place_order amount
  end
end
