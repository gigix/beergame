class RolesController < ApplicationController
  def show
    @game = Game.find(params[:game_id])
    @role = @game.roles.find(params[:id])
  end
end
