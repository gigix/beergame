class PlotsController < ApplicationController
  def show
    @graph = open_flash_chart_object(500,300,role_plot_path(params[:id]))
    render :layout => false
  end
  
  def show_team_plots
    @placed_order_graph = open_flash_chart_object(500,300,team_placed_order_plot_path(params[:id]))
    render :layout => false
  end
  
  def team_placed_order_plot
    @game = Game.find(params[:id])
    chart = open_flash_chart Title.new("订货量：游戏#{@game.name}")
   
    retailer_placed_orders = []
    wholesaler_placed_orders = []
    distributor_placed_orders = []
    factory_placed_orders = []
    (0..@game.current_week-2).to_a.each do |i|
      retailer_placed_orders << @game.roles[1].placed_orders[i].amount
      wholesaler_placed_orders << @game.roles[2].placed_orders[i].amount
      distributor_placed_orders << @game.roles[3].placed_orders[i].amount
      factory_placed_orders << @game.roles[4].placed_orders[i].amount
    end  
    
    min_y_range = [retailer_placed_orders.min, wholesaler_placed_orders.min, distributor_placed_orders.min, factory_placed_orders.min].min
    max_y_range = [retailer_placed_orders.max, wholesaler_placed_orders.max, distributor_placed_orders.max, factory_placed_orders.max].max
    y = YAxis.new
    y.set_range(min_y_range,max_y_range,100)
    chart.y_axis = y
    
    chart.add_element(create_retailer_line retailer_placed_orders)
    chart.add_element(create_wholesaler_line wholesaler_placed_orders)
    chart.add_element(create_distributor_line distributor_placed_orders)
    chart.add_element(create_factory_line factory_placed_orders)
    render :text => chart.to_s
  end
  
  def role_plot
     @role = Role.find(params[:id])
     chart = open_flash_chart Title.new("统计图：游戏#{@role.game.name}，角色#{@role.name}")
     
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
     max_y_range = [placed_orders.max, received_orders.max, inventory_histories.max].max
     y = YAxis.new
     y.set_range(min_y_range,max_y_range,100)
     chart.y_axis = y

     chart.add_element(placed_order_line)
     chart.add_element(received_order_line)
     chart.add_element(inventory_history_line)

     render :text => chart.to_s
   end
   
   private
   def open_flash_chart title
     x_legend = XLegend.new("星期")
     x_legend.set_style('{font-size: 14px; color: #778877}')

     y_legend = YLegend.new("")
     y_legend.set_style('{font-size: 14px; color: #770077}')
     chart = OpenFlashChart.new
     chart.set_title(title)
     chart.set_x_legend(x_legend)
     chart.set_y_legend(y_legend)
     chart
   end
   
   def create_retailer_line values
     retailer_line = Line.new
     retailer_line.text = "零售商"
     retailer_line.width = 3
     retailer_line.colour = '#6363AC'
     retailer_line.dot_size = 1
     retailer_line.values = values
     retailer_line
   end
   
   def create_wholesaler_line values
     wholesaler_line = Line.new
     wholesaler_line.text = "分销商"
     wholesaler_line.width = 3
     wholesaler_line.colour = '#DFC329'
     wholesaler_line.dot_size = 1
     wholesaler_line.values = values
     wholesaler_line
   end
   
   def create_distributor_line values
     distributor_line = Line.new
     distributor_line.text = "批发商"
     distributor_line.width = 3
     distributor_line.colour = '#EF35DA'
     distributor_line.dot_size = 1
     distributor_line.values = values
     distributor_line
   end
   
   def create_factory_line values
     factory_line = Line.new
     factory_line.text = "制造商"
     factory_line.width = 3
     factory_line.colour = '#5E4725'
     factory_line.dot_size = 1
     factory_line.values = values     
     factory_line
   end
end
