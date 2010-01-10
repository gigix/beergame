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
      
      consumer.name.should == 'consumer'
      consumer.downstream.should be_nil
      consumer.upstream.should == retailer
    end
  end
end
