require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Role do
  describe :place_order do
    before(:each) do
      @game = Game.create_with_roles('test_game', ['retailer', 'wholesaler', 'distributor', 'factory'])
      @consumer = @game.roles.first
      @retailer = @game.roles[1]
    end
    
    it 'increases orders placed by the current role' do
      @consumer.place_order(20)
      @consumer.placed_orders.size.should == 1
      order = @consumer.placed_orders.first
      order.role = @consumer
      order.amount = 20
    end
  end
end
