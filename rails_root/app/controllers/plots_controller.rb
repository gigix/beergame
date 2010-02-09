class PlotsController < ApplicationController
  def show
    @role = Role.find(params[:id])
    render :layout => false
  end
end
