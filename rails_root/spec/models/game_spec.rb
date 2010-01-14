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
  end
  
  describe :order_placed do
     it 'knows which role has placed order' do
      @game.order_placed(@retailer)
      @game.roles_placed_order.should == 1
      
      @game.order_placed(@wholesaler)
      @game.roles_placed_order.should == 2
      
    end
    
    it 'pass current week after order placing finished' do
      all_roles_place_order
      @game.current_week.should == 2
    end
    
    it 'consumer should place order automatically at the beginning of next week' do
      all_roles_place_order
      #@game.roles_placed_order.size.should == 1
      #@game.roles_placed_order.first.should == @consumer
    end
  end
  
  private
  def all_roles_place_order
    [@consumer, @retailer, @wholesaler, @distributor, @factory].each{|role|
      @game.order_placed(role)
    }
  end
end
