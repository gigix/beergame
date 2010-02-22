require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PlotsController do
  integrate_views
  
  include PreparedGame
  
  describe 'GET show' do
    it 'renders with given role' do
      get :show, :id => @retailer
      response.should be_success 
    end
  end
  
  describe 'GET show_team_placed_orders' do
    it 'renders with given game' do
      get :show_team_placed_orders, :id => @game
      response.should be_success
    end
  end
  
  describe 'GET show_team_received_orders' do
    it 'renders with given game' do
      get :show_team_received_orders, :id => @game
      response.should be_success
    end
  end
  
  describe 'GET show_team_inventory_histories' do
    it 'renders with given game' do
      get :show_team_inventory_histories, :id => @game
      response.should be_success
    end
  end
end
