require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe RolesController do
  integrate_views
  
  before(:each) do
    @game = Game.create_with_roles('test_game', ['retailer', 'wholesaler', 'distributor', 'factory'])
    @consumer = @game.roles.first
    @retailer = @game.roles[1]
  end
  
  describe 'GET show' do
    it 'renders with given role' do
      get :show, :id => @retailer, :game_id => @game
      response.should be_success
      assigns(:game).should == @game
      assigns(:role).should == @retailer
    end
  end
  
  describe 'POST place_order' do
    it 'place order to upstream' do
      lambda do
        post :place_order, :id => @retailer, :game_id => @game, :amount => 100
        response.should redirect_to(game_role_path(@game, @retailer))
      end.should change(Order, :count).by(1)
      
      Order.find(:all).first.role.name.should == 'retailer'
    end
  end
end
