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
  
  describe :shipping_delay_arrive do
    it 'equals the sum of shippment delay of current role and information delay of upstream' do
      @wholesaler.should_not be_shipping_delay_arrived
      @game.update_attributes(:current_week => 1 + @wholesaler.shipping_delay)
      @wholesaler.reload
      @wholesaler.should be_shipping_delay_arrived
    end
  end
  
  describe :ship do
    it 'should equals outgoing shipment' do
      @retailer.ship(8)
      order = @retailer.placed_shipments.last
      order.amount.should == 8
      order.shipper.should == @retailer
    end
    
    it 'should decrease the inventory' do
      inventory = @retailer.inventory
      @retailer.ship(8)
      @retailer.inventory.should == inventory - 8
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
    
    it 'deliver order after information delay arrived' do
      @retailer.place_order(20)
      @retailer.placed_orders.size.should == 1
      pass_delay_weeks @retailer.information_delay
      @wholesaler.received_orders.last.amount.should == 20
    end
    
    it 'should make shippment according to the order amount if has enough inventory' do
      @retailer.place_order(7)
      pass_delay_weeks @retailer.information_delay
      @wholesaler.received_orders.last.amount.should == 7
      orders = Order.find(:all, :conditions => {:amount => 7, :shipper_id => @wholesaler, :at_week => 1+@retailer.information_delay})
      orders.size.should == 1
    end
    
    it 'should ship all the inventory to the downstream if does not have enough inventory and backorder should be increased' do
      inventory = @wholesaler.inventory
      @retailer.place_order(@wholesaler.inventory + 100)
      pass_delay_weeks @retailer.information_delay
      @wholesaler.reload
      received_shipment = @wholesaler.received_shipments.last
      placed_shipment = @wholesaler.placed_shipments.last
      placed_shipment.amount.should == inventory + received_shipment.amount
      @wholesaler.inventory.should == 0
      @wholesaler.backorder.should == 100 - received_shipment.amount
    end
    
    it 'deliver shipment when shipping delay arrives' do
      pass_delay_weeks @wholesaler.shipping_delay
      @retailer.received_shipments.last.amount.should == 4
    end
    
    it 'should make shipment according to the sum of order and backorder' do
      @wholesaler.update_attributes(:backorder => 10, :inventory => 28)
      @retailer.place_order(6)
      pass_delay_weeks @retailer.information_delay
      @wholesaler.reload
      shipment = @wholesaler.received_shipments.last
      order = @wholesaler.placed_shipments.last
      order.amount.should == 16
      @wholesaler.inventory.should == 28 - 16 + shipment.amount
    end
  end  
  
  private
  def pass_delay_weeks delay
    @game.update_attributes(:current_week => @game.current_week + delay)
    @game.reload
    @game.roles.each{ |role| 
      role.update_status
    }
    @game.roles.each{ |role|
      role.reload
    }
  end
end
