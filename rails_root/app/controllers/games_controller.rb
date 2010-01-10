class GamesController < ApplicationController
  def index
    @games = Game.find(:all)
  end
  
  def create
    Game.create_with_roles(params[:game][:name], ['retailer', 'wholesaler', 'distributor', 'factory'])
    redirect_to games_path
  end
  
  def show
    @game = Game.find(params[:id])
  end
end
