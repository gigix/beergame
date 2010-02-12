class RolesController < ApplicationController
  def show
    @game = Game.find(params[:game_id])
    @role = @game.roles.find(params[:id])
    @graph = open_flash_chart_object(500,300,graph_path(@role.id))
  end
  
  def place_order
    @game = Game.find(params[:role][:game_id])
    @role = @game.roles.find(params[:role][:id])
    amount = params[:role][:placed_orders][:amount]
    @role.place_order(amount)
    redirect_to game_role_path(@game, @role)
  end
  
  def graph
    @role = Role.find(params[:id])
    title = Title.new("统计图：游戏#{@role.game.name}，角色#{@role.name}")
    received_orders = []
    placed_orders = []
    inventory_histories = []
    week = @role.received_orders.length
    (0..week-1).to_a.each do |i|
      received_orders << @role.received_orders[i].amount
      placed_amount = @role.placed_orders[i].nil?? 0 : @role.placed_orders[i].amount
      placed_orders << placed_amount
      inventory_histories << @role.inventory_histories[i].amount 
    end
    
    placed_order_line = Line.new
    placed_order_line.text = "订货量"
    placed_order_line.width = 3
    placed_order_line.colour = '#6363AC'
    placed_order_line.dot_size = 1
    placed_order_line.values = placed_orders
    
    received_order_line = Line.new
    received_order_line.text = "需求量"
    received_order_line.width = 3
    received_order_line.colour = '#DFC329'
    received_order_line.dot_size = 1
    received_order_line.values = received_orders


    inventory_history_line = Line.new
    inventory_history_line.text = "库存量"
    inventory_history_line.width = 3
    inventory_history_line.colour = '#5E4725'
    inventory_history_line.dot_size = 1
    inventory_history_line.values = inventory_histories

    min_y_range = inventory_histories.min
    max_placed_order = placed_orders.max
    max_received_order = received_orders.max
    max_inventory = inventory_histories.max
    max_y_range = [max_placed_order, max_received_order, max_inventory].max
    y = YAxis.new
    y.set_range(min_y_range,max_y_range,100)

    x_legend = XLegend.new("星期")
    x_legend.set_style('{font-size: 14px; color: #778877}')

    y_legend = YLegend.new("")
    y_legend.set_style('{font-size: 14px; color: #770077}')

    chart =OpenFlashChart.new
    chart.set_title(title)
    chart.set_x_legend(x_legend)
    chart.set_y_legend(y_legend)
    chart.y_axis = y
    
    chart.add_element(placed_order_line)
    chart.add_element(received_order_line)
    chart.add_element(inventory_history_line)

    render :text => chart.to_s
  end
end
