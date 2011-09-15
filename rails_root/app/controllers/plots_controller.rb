class PlotsController < ApplicationController
  include PlotsHelper
  
  def show
    @graph = open_flash_chart_object(1000,600,role_plot_path(params[:id]))
    render :layout => false
  end
  
  def show_team_plot
    method_type = params[:method_type]
    @graph = open_flash_chart_object(1000,600,team_plot_path(params[:id], method_type))
    render :layout => false
  end
  
  def team_plot
    @game = Game.find(params[:id])
    method_type = params[:method_type]    
    title = plot_title(method_type)
    
    x_label_values = []
    (1..@game.roles.length-2).each{ |i|
      instance_eval %Q{
       #{@game.roles[i].english_name}_data=[] 
      }
    }
    (0..@game.current_week-2).to_a.each do |week|
      (1..@game.roles.length-2).each{ |i|
        instance_eval %Q{
         #{@game.roles[i].english_name}_data << @game.roles[i].instance_eval(method_type)[week].amount
        }
      }
      retailer_data << @game.roles[1].instance_eval(method_type)[i].amount
      wholesaler_data << @game.roles[2].instance_eval(method_type)[i].amount
      distributor_data << @game.roles[3].instance_eval(method_type)[i].amount
      factory_data << @game.roles[4].instance_eval(method_type)[i].amount
      x_label_values << (week+1).to_s
    end  
  
    min_y_range = min([min(retailer_data), min(wholesaler_data), min(distributor_data), min(factory_data)])
    max_y_range = max([max(retailer_data), max(wholesaler_data), max(distributor_data), max(factory_data)])
    y = YAxis.new
    y.set_range(min_y_range,max_y_range+100,100)
    
    chart = open_flash_chart(Title.new("#{title}"), create_x_axis(x_label_values), y)
  
    chart.add_element(create_retailer_line(retailer_data))
    chart.add_element(create_wholesaler_line(wholesaler_data))
    chart.add_element(create_distributor_line(distributor_data))
    chart.add_element(create_factory_line(factory_data))
    render :text => chart.to_s
  end
  
  def role_plot
     @role = Role.find(params[:id])

     x_label_values = []
     received_orders = []
     placed_orders = []
     inventory_histories = []
     cost_histories = []
     (0..@role.game.current_week-2).to_a.each do |i|
       received_orders << @role.received_orders[i].amount
       placed_amount = @role.placed_orders[i].nil?? 0 : @role.placed_orders[i].amount
       placed_orders << placed_amount
       inventory_histories << @role.inventory_histories[i].amount 
       cost_histories << @role.cost_histories[i].amount
       x_label_values << (i+1).to_s
     end
     
     min_y_range = min([min(placed_orders), min(received_orders), min(inventory_histories)])
     max_y_range = max([max(placed_orders), max(received_orders), max(inventory_histories)])
     y = YAxis.new
     y.set_range(min_y_range,max_y_range+100,100)
     
     chart = open_flash_chart(Title.new("统计图：游戏#{@role.game.name}，角色#{@role.name}"), create_x_axis(x_label_values), y)

     chart.add_element(create_placed_order_line(placed_orders))
     chart.add_element(create_received_order_line(received_orders))
     chart.add_element(create_inventory_history_line(inventory_histories))
     chart.add_element(create_cost_history_line(cost_histories))

     render :text => chart.to_s
   end

   private
   def min(arr)
     arr.min rescue 0
   end
   
   def max(arr)
     arr.max rescue 0
   end
   
   def create_x_axis x_label_values
     x_labels = XAxisLabels.new
     x_labels.labels = x_label_values
     x = XAxis.new
     x.set_labels(x_labels)
     x
   end
   
   def open_flash_chart title, x_axis, y_axis
     x_legend = XLegend.new("星期")
     x_legend.set_style('{font-size: 14px; color: #778877}')

     y_legend = YLegend.new("")
     y_legend.set_style('{font-size: 14px; color: #770077}')
     chart = OpenFlashChart.new
     chart.set_title(title)
     chart.set_x_legend(x_legend)
     chart.set_y_legend(y_legend)
     chart.x_axis = x_axis
     chart.y_axis = y_axis
     chart
   end
   
   def create_line text, color, values
     line = new_line
     line.text = text
     line.colour = color
     line.values = values
     line
   end
   
   def create_cost_history_line values
     create_line "成本", '#31D310', values
   end
   
   def create_received_order_line values
     create_line "需求量", '#DFC329', values
   end
   
   def create_placed_order_line values
     create_line "订货量", '#6363AC', values
   end
   
   def create_inventory_history_line values
     create_line "库存量", '#5E4725', values
   end
   
   def create_retailer_line values
     create_line "零售商", '#6363AC', values
   end
   
   def create_wholesaler_line values
     create_line "分销商", '#DFC329', values
   end
   
   def create_distributor_line values
     create_line "批发商", '#EF35DA', values
   end
   
   def create_factory_line values
     create_line "制造商", '#5E4725', values     
   end
   
   def new_line
     line = Line.new
     line.width = 3
     line.dot_size = 1
     line
   end
end
