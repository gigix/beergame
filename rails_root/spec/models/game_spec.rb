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
    
    it 'consumer will place order after game created' do
      consumer = @game.roles.first
      consumer.placed_orders.size.should == 1
    end
  end
  
  describe 'self.order_placed' do
    
    it 'do not pass current week if order placing not finished' do
      [@consumer, @retailer, @wholesaler, @distributor].each{|role|
        role.update_attributes(:order_placed => true)
      }
      @game.order_placed
      @game.current_week.should == 1
    end
    
    it 'pass current week after order placing finished' do
      [@consumer, @retailer, @wholesaler, @distributor, @factory].each{|role|
        role.update_attributes(:order_placed => true)
      }
      @game.order_placed
      @game.current_week.should == 2
    end
  end
end
