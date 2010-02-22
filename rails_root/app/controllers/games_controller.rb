class GamesController < ApplicationController
  def index
    @games = Game.find(:all)
  end
  
  def create
    Game.create_with_roles(params[:game][:name], ['零售商', '分销商', '批发商', '制造商'])
    redirect_to games_path
  end
  
  def show
    @game = Game.find(params[:id])
  end
  
  def edit
    @game = Game.find(params[:id])
  end
  
  def update
    game = Game.find(params[:id])
    game.update_attributes(params[:game])
    redirect_to games_path
  end
end
