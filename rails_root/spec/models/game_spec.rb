require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Game do
  include PreparedGame
  
  describe 'self.create_with_roles' do
        
    it 'creates game and roles' do
      Game.count.should == 1
      @game.roles.count.should == 6
    end
    
    it 'associates roles' do
      consumer = @game.roles.first
      retailer = @game.roles[1]
      wholesaler = @game.roles[2]
      brewery = @game.roles.last
      
      consumer.should_not be_playable
      retailer.should be_playable
      wholesaler.should be_playable
      brewery.should_not be_playable
      
      consumer.name.should == '顾客'
      consumer.downstream.should be_nil
      consumer.upstream.should == retailer
      retailer.downstream.should == consumer
      retailer.upstream.should == wholesaler
      wholesaler.downstream.should == retailer
    end

    it 'each role should have initial inventory after game created' do
      @game.roles[1..@game.roles.length-2].each{ |role|
        role.inventory.should == 12
      }
    end
    
    it 'each role should have none empty inventory history list after game created' do
      @game.roles[1..@game.roles.length-2].each{ |role|
        role.inventory_histories.first.amount.should == 12
      }
    end
    
    it 'brewer should have a large inventory which is max int value' do
      @game.roles.last.inventory.should == Game::MAX_INVENTORY
    end
    
    it 'all roles should receive order after game created' do
      @game.roles[1..@game.roles.size-1].each{ |role|
        role.received_orders.size.should == 1
        order = role.received_orders[0]
        order.amount.should == 4
        order.at_week.should == 1
      }
    end
    
    it 'all roles should receive shipment after game created' do
      @game.roles[1..@game.roles.size-2].each{ |role|
        role.received_shipments.size.should == 1
        order = role.received_shipments[0]
        order.amount.should == 4
        order.at_week.should == 1
      }
    end
    
    it 'game places order will not increase placed_orders that belongs to role' do
      @game.roles.each{ |role|
        role.placed_orders.size.should == 0
      }
    end
    
    it 'orders placed by game should not have sender' do
      @retailer.received_orders.first.sender.should == nil
    end

    it 'game should have initial inventory/backorder cost' do
      @game.inventory_cost.should == 0.5
      @game.backorder_cost.should == 1
    end
    
    it 'each role should have none empty cost history list after game create' do
      @game.roles[1..@game.roles.length-2].each{ |role|
        role.cost_histories.first.amount.should == role.inventory * @game.inventory_cost
      }
    end
  end
  
  describe :order_placed do
    
    it 'do not pass current week if order placing not finished' do
      [@retailer, @wholesaler, @distributor].each{|role|
        role.place_order(100)
      }
      @game.current_week.should == 1
    end
    
    it 'pass current week after order placing finished' do
      all_roles_place_order
      @game.reload
      @game.current_week.should == 2
    end
    
    it 'the requirement from consumer should be doubled from the 2nd week' do
      all_roles_place_order 
      
      retailer = @game.roles[1]
      retailer.received_orders.last.amount.should ==  2 * retailer.received_orders.first.amount
      retailer.received_orders.last.at_week.should == 2
      
      retailer.placed_shipments.last.amount.should == retailer.received_orders.last.amount
    end

     
    it 'the roles except for customer should keep receiving order placed by game during the information delay time' do
      all_roles_place_order  
      @game.roles[2..@game.roles.size-2].each{ |role|
        role.received_orders.size.should == 2
        order = role.received_orders[1]
        order.amount.should == 4
        order.at_week.should == 2
        order.sender.should == nil
      } 
    end
    
    it 'the roles except for customer should receive order from downstream after information delay' do
      all_roles_place_order
      @brewery.received_orders.last.amount.should == 100
      
      (@game.roles[2].information_delay - 1).times{
        all_roles_place_order
      }
      @game.reload
      @game.current_week.should == 3
      @wholesaler.received_orders.last.amount.should == 100
    end
    
    it 'the roles except for brewery should receive shipment placed by game during the information delay' do
      all_roles_place_order
      @game.roles[1..@game.roles.size-2].each{ |role|
        role.received_shipments.size.should == 2
        shipment = role.received_shipments[1]
        shipment.amount.should == 4
        shipment.at_week.should == 2
        shipment.sender.should == nil
      }
    end
    
    it 'the roles should receive shipment from upstream after the information delay and shipping delay' do
      2.times{
        all_roles_place_order
      }
      @factory.received_shipments.last.amount.should == 100
    end
    
    it 'integration test' do
      [@retailer, @wholesaler, @distributor, @factory].each{|role|
        role.reload
        role.place_order(5)
      }
      [@retailer, @wholesaler, @distributor, @factory].each{|role|
        role.reload
        role.place_order(6)
      }
      [@retailer, @wholesaler, @distributor, @factory].each{|role|
        role.reload
        role.place_order(7)
      }
      [@retailer, @wholesaler, @distributor, @factory].each{|role|
        role.reload
        role.place_order(8)
      }
      @retailer.reload
      @retailer.received_shipments.last.amount.should == 5
      @retailer.inventory.should == -3
      @retailer.backorder.should == 3
    end
  end
  
  private
  def all_roles_place_order
    [@retailer, @wholesaler, @distributor, @factory].each{|role|
      role.reload
      role.place_order(100)
    }
  end
end
