class Game < ActiveRecord::Base
  has_many :roles
  
  def self.create_with_roles(name, role_names)
    game = create!(:name => name)
    
    current_role = game.roles.create!(:name => 'consumer')
    role_names.push('brewery').each do |role_name| 
      upper_role = game.roles.create!(:name => role_name)
      current_role.update_attributes(:upstream => upper_role)
      current_role = upper_role
    end
    
    game
  end
end
