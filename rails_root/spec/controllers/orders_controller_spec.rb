require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe OrdersController do
  integrate_views
  
  include PreparedGame
  
  describe 'POST create' do
    it 'role places order' do
      lambda do
        post :create, :role => {:id => @retailer, :game_id => @game, :placed_orders => {:amount => 100}}
        response.should redirect_to(game_role_path(@game, @retailer))
      end.should change(Order, :count).by(1)
      
    end
  end
end
