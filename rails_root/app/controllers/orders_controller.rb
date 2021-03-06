class OrdersController < ApplicationController

  def create
    @game = Game.find(params[:role][:game_id])
    @role = @game.roles.find(params[:role][:id])
    amount = params[:role][:placed_orders][:amount]
    @role.place_order(amount)
    redirect_to game_role_path(@game, @role)
  end
end
