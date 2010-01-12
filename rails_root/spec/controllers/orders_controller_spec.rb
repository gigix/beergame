require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe OrdersController do
  integrate_views
  
  before(:each) do
    @game = Game.create_with_roles('test_game', ['retailer', 'wholesaler', 'distributor', 'factory'])
    @consumer = @game.roles.first
    @retailer = @game.roles[1]
  end
  
  describe 'POST create' do
    it 'role places order' do
      lambda do
        post :create, :role => {:id => @retailer, :game_id => @game, :placed_orders => {:amount => 100}}
        response.should redirect_to(game_role_path(@game, @retailer))
      end.should change(Order, :count).by(1)
      
      Order.find(:all).first.sender.name.should == 'retailer'
      Order.find(:all).first.inbox.name.should == 'wholesaler'
    end
  end
end
