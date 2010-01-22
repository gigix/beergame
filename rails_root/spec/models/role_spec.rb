require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Role do
  include PreparedGame
  
  describe :place_order do
    before(:each) do
      @retailer.place_order(20)
      @order = @retailer.placed_orders.first
    end
    
    it 'increases orders placed by the current role' do   
      @retailer.placed_orders.size.should == 1
      @order.sender.should == @retailer
      @order.amount.should == 20
      @order.at_week.should == 1
    end
    
    it 'increases inbox orders of upstream' do
      @order.should == @wholesaler.inbox_orders.first
      @order.inbox.should == @wholesaler
    end
    
    it 'the role has placed order' do
      @retailer.should be_order_placed
    end
    
    it 'cannot place order twice in the same week' do
      @retailer.place_order(50)
      @retailer.placed_orders.size.should == 1
      @order.amount.should == 20
    end
  end
  
  describe :information_delay_arrived do
    it 'calculates the time duration between current week and start week' do
      @wholesaler.should_not be_information_delay_arrived
      @game.update_attributes(:current_week => 1 + @wholesaler.information_delay)
      @wholesaler.reload
      @wholesaler.should be_information_delay_arrived
    end
  end
  
  describe :update_status do
    it 'should be able to place order again as status updated' do
      @retailer.place_order(20)
      @retailer.update_status
      @retailer.place_order(50)
      @retailer.placed_orders.size.should == 2
      @retailer.placed_orders.first.amount.should == 20
      @retailer.placed_orders[1].amount.should == 50
    end
    
    it 'place order from inbox to received_order which matches information delay' do
      @retailer.place_order(20)
      @wholesaler.inbox_orders.size.should == 1
      @game.update_attributes(:current_week => 1 + @wholesaler.information_delay)
      @wholesaler.update_status
      @wholesaler.inbox_orders.size.should == 0
      orders = Order.find(:all, :conditions => {:amount => 20, :sender_id => @retailer, :receiver_id => @wholesaler})
      orders.size.should == 1
      orders[0].at_week.should == 3
    end
  end  
end
