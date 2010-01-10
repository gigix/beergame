class Game < ActiveRecord::Base
  has_many :roles
  
  def self.create_with_roles(name, role_names)
    game = create!(:name => name)
    
    last_role = game.roles.create!(:name => 'consumer')
    role_names.push('brewery').each do |role_name| 
      upper_role = game.roles.create!(:name => role_name, :playable => true)
      last_role.update_attributes(:upstream => upper_role)
      last_role = upper_role
    end
    
    last_role.update_attributes(:playable => false)
    game
  end
end
