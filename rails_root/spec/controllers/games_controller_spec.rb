require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe GamesController do
  integrate_views
  
  include PreparedGame
  
  describe 'GET index' do
    it 'lists all games' do
      get :index
      assigns(:games).should == [@game]
      response.should be_success
    end
  end
  
  describe 'POST create' do
    it 'creates default game with a name' do
      lambda do
        post :create, :game => {:name => 'test game'}
        response.should redirect_to(games_path)
      end.should change(Game, :count).by(1)
      
      Game.find(:all).last.name.should == 'test game'
    end
  end
  
  describe 'GET show' do
    it 'shows given game' do
      get :show, :id => @game
      assigns(:game).should == @game
      response.should be_success
    end
  end
  
  describe 'GET edit' do
    it 'show game information' do
      get :edit, :id => @game
      assigns(:game).should == @game
      response.should be_success
    end
  end
  
  describe 'PUT update' do
    it 'update game information' do
      put :update, :id => @game, :game => {:inventory_cost => 3, :backorder_cost => 5}
      response.should redirect_to(games_path)
      game = Game.find(@game)
      game.inventory_cost.should == 3
      game.backorder_cost.should == 5
    end
  end
end
