require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Role do
  include PreparedGame
  
  describe :place_order do
    before(:each) do
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
