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
  
  describe :back_order do
    it 'back_order should be 0 if has inventory' do
      @wholesaler.update_attributes(:inventory => 2)
      @wholesaler.backorder.should == 0
    end
    
    it 'back_order should be inventory.abs if inventory < 0' do
      @wholesaler.update_attributes(:inventory => -9)
      @wholesaler.backorder.should == 9 
    end
  end
  
  describe :deliver_placed_orders do
    it 'should deliver order after information delay arrived' do
      @retailer.place_order(20)
      @retailer.placed_orders.size.should == 1
      @game.update_attributes(:current_week => @game.current_week + @retailer.information_delay)
      @retailer.reload
      @retailer.deliver_placed_orders
      @wholesaler.reload
      @wholesaler.received_orders.last.amount.should == 20
    end
  end
  
  describe :deliver_placed_shipments do
    it 'deliver shipment when shipping delay arrives' do
      @wholesaler.placed_shipments.create!(:amount => 17, :at_week => 7)
      @game.update_attributes(:current_week => 7 + @wholesaler.shipping_delay)
      @wholesaler.reload
      @wholesaler.deliver_placed_shipments
      @retailer.reload
      @retailer.received_shipments.last.amount.should == 17
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
    
    it 'should make shippment according to the order amount if has enough inventory' do
      inventory = @wholesaler.inventory
      @game.update_attributes(:current_week => 9)
      @wholesaler.reload
      @wholesaler.received_orders.create!(:amount => 7)
      @wholesaler.received_shipments.create!(:amount => 5)
      @wholesaler.update_status
      placed_shipment = @wholesaler.placed_shipments.last
      placed_shipment.amount.should == 7
      placed_shipment.at_week.should == 9 
      placed_shipment.shipper.should == @wholesaler
      @wholesaler.inventory.should == inventory - 7 + 5
    end
    
    it 'should ship all the inventory to the downstream if does not have enough inventory and backorder should be increased' do
      inventory = @wholesaler.inventory
      @wholesaler.received_orders.create!(:amount => inventory + 100)
      @wholesaler.received_shipments.create!(:amount => 5)
      @wholesaler.update_status
      placed_shipment = @wholesaler.placed_shipments.last
      placed_shipment.amount.should == inventory + 5
      @wholesaler.inventory.should == -95
      @wholesaler.backorder.should == 95
    end

    it 'should make shipment according to the sum of order and backorder' do
      @wholesaler.update_attributes(:inventory => -28)
      @wholesaler.received_orders.create!(:amount => 6)
      @wholesaler.received_shipments.create!(:amount => 7)
      @wholesaler.update_status
      order = @wholesaler.placed_shipments.last
      order.amount.should == 7
      @wholesaler.inventory.should == -27
      @wholesaler.inventory_histories.size.should == 2
      @wholesaler.inventory_histories.last.amount.should == -27
    end
    
    it 'should make a new record of inventory history' do
      @wholesaler.update_status
      inventory_history = @wholesaler.inventory_histories.last
      inventory_history.role.should == @wholesaler
      inventory_history.amount.should == 12
      inventory_history.at_week.should == 1
    end
  end  
end
