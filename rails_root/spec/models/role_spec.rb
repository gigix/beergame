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
    
    it 'do not pass current week if order placing not finished' do
      @wholesaler.place_order(50)
      @distributor.place_order(60)
      @game.current_week.should == 1
    end
    
    it 'pass current week after order placing finished' do
      all_roles_place_order
      @game.reload
      @game.current_week.should == 2
      consumer = @game.roles.first
      consumer.should be_order_placed
      consumer.placed_orders.size.should == 2
      consumer.placed_orders[1].amount.should == 4
      consumer.placed_orders[1].at_week.should == 2
    end
  end
  
  describe :update_status do
    it 'should be able to place order again as week passed' do
      @retailer.place_order(20)
      @retailer.update_status
      @retailer.place_order(50)
      @retailer.placed_orders.size.should == 2
      @retailer.placed_orders.first.amount.should == 20
      @retailer.placed_orders[1].amount.should == 50
    end
  end  
  
  private
    def all_roles_place_order
      [@consumer, @retailer, @wholesaler, @distributor, @factory].each{|role|
        role.place_order(100)
      }
    end
end
