require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Game do
  describe 'self.create_with_roles' do
    before(:each) do
      @game = Game.create_with_roles('test_game', ['retailer', 'wholesaler', 'distributor', 'factory'])
    end
    
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
end
