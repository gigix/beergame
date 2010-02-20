class PlotsController < ApplicationController
  def show
    @graph = open_flash_chart_object(500,300,role_plot_path(params[:id]))
    render :layout => false
  end
  
  { "placed_orders" => "订货量", 
    "received_orders" => "需求量",
    "inventory_histories" => "库存量"
  }.each do |method_type, title|
    class_eval <<-team_plots
      def show_team_#{method_type}
        @#{method_type}_graph = open_flash_chart_object(500,300,team_#{method_type}_plot_path(params[:id]))
        render :layout => false
      end
      
      def team_#{method_type}_plot
        @game = Game.find(params[:id])
        chart = open_flash_chart Title.new("#{title}")

        retailer_#{method_type} = []
        wholesaler_#{method_type} = []
        distributor_#{method_type} = []
        factory_#{method_type} = []
        (0..@game.current_week-2).to_a.each do |i|
          retailer_#{method_type} << @game.roles[1].#{method_type}[i].amount
          wholesaler_#{method_type} << @game.roles[2].#{method_type}[i].amount
          distributor_#{method_type} << @game.roles[3].#{method_type}[i].amount
          factory_#{method_type} << @game.roles[4].#{method_type}[i].amount
        end  

        min_y_range = [retailer_#{method_type}.min, wholesaler_#{method_type}.min, distributor_#{method_type}.min, factory_#{method_type}.min].min
        max_y_range = [retailer_#{method_type}.max, wholesaler_#{method_type}.max, distributor_#{method_type}.max, factory_#{method_type}.max].max
        y = YAxis.new
        y.set_range(min_y_range,max_y_range,100)
        chart.y_axis = y

        chart.add_element(create_retailer_line retailer_#{method_type})
        chart.add_element(create_wholesaler_line wholesaler_#{method_type})
        chart.add_element(create_distributor_line distributor_#{method_type})
        chart.add_element(create_factory_line factory_#{method_type})
        render :text => chart.to_s
      end
    team_plots
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

     min_y_range = inventory_histories.min
     max_y_range = [placed_orders.max, received_orders.max, inventory_histories.max].max
     y = YAxis.new
     y.set_range(min_y_range,max_y_range,100)
     chart.y_axis = y

     chart.add_element(create_placed_order_line placed_orders)
     chart.add_element(create_received_order_line received_orders)
     chart.add_element(create_inventory_history_line inventory_histories)

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
   
   def create_received_order_line values
     received_order_line = new_line
     received_order_line.text = "需求量"
     received_order_line.colour = '#DFC329'
     received_order_line.values = values
     received_order_line
   end
   
   def create_placed_order_line values
     placed_order_line = new_line
     placed_order_line.text = "订货量"
     placed_order_line.colour = '#6363AC'
     placed_order_line.values = values
     placed_order_line
   end
   
   def create_inventory_history_line values
     inventory_history_line = new_line
     inventory_history_line.text = "库存量"
     inventory_history_line.colour = '#5E4725'
     inventory_history_line.values = values
     inventory_history_line
   end
   
   def create_retailer_line values
     retailer_line = new_line
     retailer_line.text = "零售商"
     retailer_line.colour = '#6363AC'
     retailer_line.values = values
     retailer_line
   end
   
   def create_wholesaler_line values
     wholesaler_line = new_line
     wholesaler_line.text = "分销商"
     wholesaler_line.colour = '#DFC329'
     wholesaler_line.values = values
     wholesaler_line
   end
   
   def create_distributor_line values
     distributor_line = new_line
     distributor_line.text = "批发商"
     distributor_line.colour = '#EF35DA'
     distributor_line.values = values
     distributor_line
   end
   
   def create_factory_line values
     factory_line = new_line
     factory_line.text = "制造商"
     factory_line.colour = '#5E4725'
     factory_line.values = values     
     factory_line
   end
   
   def new_line
     line = Line.new
     line.width = 3
     line.dot_size = 1
     line
   end
end
