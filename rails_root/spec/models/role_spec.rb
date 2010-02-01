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
  
  describe :ship do
    it 'should equals outgoing shipment' do
      @retailer.ship(8)
      order = @retailer.outgoing_shipments.first
      order.amount.should == 8
      order.shipper.should == @retailer
      order.logistics.should == @consumer
    end
    
    it 'should decrease the inventory' do
      inventory = @retailer.inventory
      @retailer.ship(8)
      @retailer.inventory.should == inventory - 8
    end
    
    it 'should increase logistics of downstream' do
      @retailer.ship(8)
      order = @retailer.outgoing_shipments.first
      @consumer.logistics.first.should == order
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
    
    it 'move order from inbox to received_order which matches information delay' do
      @retailer.place_order(20)
      @wholesaler.inbox_orders.size.should == 1
      pass_delay_weeks @wholesaler.information_delay
      @wholesaler.inbox_orders.size.should == 0
      orders = Order.find(:all, :conditions => {:amount => 20, :sender_id => @retailer, :receiver_id => @wholesaler})
      orders.size.should == 1
      orders[0].at_week.should == 3
    end
    
    it 'should make shippment according to the order amount if has enough inventory' do
      @retailer.place_order(8)
      @wholesaler.outgoing_shipments.size.should == 0
      pass_delay_weeks @retailer.information_delay
      wholesaled_outgoing_shipment = @wholesaler.outgoing_shipments.first
      wholesaled_outgoing_shipment.amount.should == 8
      retailer_logistics = @retailer.logistics.first
      retailer_logistics.amount.should == 8
    end
    
    it 'should ship all the inventory to the downstream if does not have enough inventory' do
      inventory = @wholesaler.inventory
      retailer_place_order_larger_than_wholesaler_inventory
      order = @wholesaler.outgoing_shipments.first
      order.amount.should == inventory
      @wholesaler.inventory.should == 0
    end
    
    it 'move shipment from logistics to incoming_shipment which matches shipping delay' do
      @wholesaler.ship(8)
      @retailer.logistics.length.should == 1
      pass_delay_weeks @retailer.shipping_delay
      @retailer.logistics.length.should == 0
      orders = Order.find(:all, :conditions => {:amount => 8, :shipper_id => @wholesaler, :shipment_receiver_id => @retailer})
      orders.size.should == 1
      orders[0].amount.should == 8
    end

    it 'incoming shipment should increase the total inventory' do
      inventory = @retailer.inventory
      @retailer.place_order(9)
      pass_delay_weeks @retailer.information_delay
      pass_delay_weeks @retailer.shipping_delay
      @retailer.incoming_shipments.first.amount.should ==9
      @retailer.inventory.should == inventory + 9
    end
    
    it 'should increase backorder if does not have enough inventory for ship' do
      retailer_place_order_larger_than_wholesaler_inventory
      @wholesaler.backorder.should == 10
      retailer_place_order_larger_than_wholesaler_inventory
      @wholesaler.backorder.should == 20
    end
    
    it 'should make shipment according to the sum of order and backorder' do
      retailer_place_order_larger_than_wholesaler_inventory
      @wholesaler.backorder.should == 10
      @wholesaler.update_attributes(:inventory => 20)
      @retailer.place_order(12)
      pass_delay_weeks @retailer.information_delay
      order = @wholesaler.outgoing_shipments.last
      order.amount.should == 20
      @wholesaler.inventory.should == 0
      @wholesaler.backorder.should == 2
    end
  end  
  
  private
  def pass_delay_weeks delay
    @game.update_attributes(:current_week => @game.current_week + delay)
    @game.roles.each{ |role| 
      role.update_status
      role.reload
    }
  end
  
  def retailer_place_order_larger_than_wholesaler_inventory
    @retailer.place_order(@wholesaler.inventory + 10)
    pass_delay_weeks @retailer.information_delay
  end
end
