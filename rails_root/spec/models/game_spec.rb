require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Game do
  include PreparedGame
  
  describe 'self.create_with_roles' do
        
    it 'creates game and roles' do
      Game.count.should == 1
      @game.roles.count.should == 6
    end
    
    it 'associates roles' do
      consumer = @game.roles.first
      retailer = @game.roles[1]
      wholesaler = @game.roles[2]
      brewery = @game.roles.last
      
      consumer.should_not be_playable
      retailer.should be_playable
      wholesaler.should be_playable
      brewery.should_not be_playable
      
      consumer.name.should == 'consumer'
      consumer.downstream.should be_nil
      consumer.upstream.should == retailer
      retailer.downstream.should == consumer
      retailer.upstream.should == wholesaler
      wholesaler.downstream.should == retailer
    end
    
    it 'game places order will not increase placed_orders that belongs to role' do
      @game.roles.each{ |role|
        role.placed_orders.size.should == 0
      }
    end
    
    it 'all roles should receive order after game created' do
      @game.roles[1..@game.roles.size-1].each{ |role|
        role.received_orders.size.should == 1
        order = role.received_orders[0]
        order.amount.should == 4
        order.at_week.should == 1
      }
    end
    
    it 'orders placed by game should not have sender' do
      @retailer.received_orders.first.sender.should == nil
    end
  end
  
  describe 'self.order_placed' do
    
    it 'do not pass current week if order placing not finished' do
      [@retailer, @wholesaler, @distributor].each{|role|
        role.place_order(100)
      }
      @game.current_week.should == 1
    end
    
    it 'pass current week after order placing finished' do
      all_roles_place_order
      @game.reload
      @game.current_week.should == 2
    end
    
    it 'the role nearest to the consumer should receive the order from consumer' do
      all_roles_place_order 
      
      retailer = @game.roles[1]
      retailer.received_orders.last.amount.should == 8
      retailer.received_orders.last.at_week.should == 2
    end
     
    it 'all the other roles should keep receiving order placed by during the information delay time' do
      all_roles_place_order 
        
      @game.roles[2..@game.roles.size-2].each{ |role|
        role.received_orders.size.should == 2
        order = role.received_orders[1]
        order.amount.should == 4
        order.at_week.should == 2
        order.sender.should == nil
      }
      
    end
    
    it 'all the other roles should receive order from downstream after information delay' do
      all_roles_place_order
      @brewery.received_orders.last.amount.should == 100
      
      (@game.roles[2].information_delay - 1).times{
        all_roles_place_order
      }
      @game.reload
      @game.current_week.should == 3
      @wholesaler.received_orders.last.amount.should == 100
    end
  end
  
  private
  def all_roles_place_order
    [@retailer, @wholesaler, @distributor, @factory].each{|role|
      role.reload
      role.place_order(100)
    }
  end
end
