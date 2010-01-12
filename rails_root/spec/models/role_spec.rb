require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Role do
  describe :place_order do
    before(:each) do
      @game = Game.create_with_roles('test_game', ['retailer', 'wholesaler', 'distributor', 'factory'])
      @consumer = @game.roles.first
      @retailer = @game.roles[1]
      @consumer.place_order(20)
      @order = @consumer.placed_orders.first
    end
    
    it 'increases orders placed by the current role' do
      @consumer.placed_orders.size.should == 1
      @order.sender.should == @consumer
      @order.amount.should == 20
    end
    
    it 'increases inbox orders of upstream' do
      @order.should == @retailer.inbox_orders.first
      @order.inbox.should == @retailer
    end
  end
end
