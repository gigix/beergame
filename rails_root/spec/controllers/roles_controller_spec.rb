require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe RolesController do
  integrate_views
  
  include PreparedGame
  
  describe 'GET show' do
    it 'renders with given role' do
      get :show, :id => @retailer, :game_id => @game
      response.should be_success
      assigns(:game).should == @game
      assigns(:role).should == @retailer
    end
    
    it 'should be success when game over' do;
      @game.update_attributes(:max_weeks => 1, :current_week => 1)
      get :show, :id => @retailer, :game_id => @game
      response.should be_success
    end
    
  end
end
