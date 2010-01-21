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
    
    it 'the role has placed order' do
      @consumer.should be_order_placed
    end
    
    it 'cannot place order twice in the same week' do
      @consumer.place_order(50)
      @consumer.placed_orders.size.should == 1
      @order.amount.should == 20
    end
    
    it 'do not pass current week if order placing not finished' do
      @retailer.place_order(40)
      @wholesaler.place_order(50)
      @distributor.place_order(60)
      @game.current_week.should == 1
    end
    
    it 'pass current week after order placing finished' do
      all_roles_place_order
      @game.reload.current_week.should == 2
      @consumer.reload
      @consumer.should be_order_placed
      @consumer.placed_orders.size.should == 2
      @consumer.placed_orders[1].amount.should == 4
    end
  end
  
  describe :update_status do
    it 'should be able to place order again as week passed' do
      @consumer.place_order(20)
      @consumer.update_status
      @consumer.place_order(50)
      @consumer.placed_orders.size.should == 2
      @consumer.placed_orders.first.amount.should == 20
      @consumer.placed_orders[1].amount.should == 50
    end
  end  
  
  private
    def all_roles_place_order
      [@consumer, @retailer, @wholesaler, @distributor, @factory].each{|role|
        role.place_order(100)
      }
    end
end
