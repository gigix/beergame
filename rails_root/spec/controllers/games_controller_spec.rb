require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe GamesController do
  before(:each) do
    @game = Game.create_with_roles('test_game', ['retailer', 'wholesaler', 'distributor', 'factory'])
  end
  
  describe 'GET index' do
    it 'lists all games' do
      get :index
      assigns(:games).should == [@game]
    end
  end
end
