class PlotsController < ApplicationController
  include PlotsHelper
  @@colors = ['#31D310', '#6363AC', '#DFC329', '#5E4725']
  
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
    
    for_each_playable_role { |role_index|
      instance_variable_set("@#{@game.roles[role_index].english_name}", [])
    }

    (0..@game.current_week-2).to_a.each do |week|
      for_each_playable_role{ |role_index|
        data_of_role(role_index) << @game.roles[role_index].instance_eval(method_type)[week].amount
      }
    end  
  
    y_axis = YAxis.new    
    y_axis.set_range(min(data_of_roles), max(data_of_roles)+100, 100)
    
    chart = open_flash_chart(Title.new("#{title}"), create_x_axis(populate_x_label_values(@game)), y_axis)
    
    (1..@game.roles.length-2).each{ |role_index|
       chart.add_element(
          create_line("#{@game.roles[role_index].name}", @@colors[role_index-1], data_of_role(role_index))
       )
    }
    
    render :text => chart.to_s
  end
  
  def role_plot
     @role = Role.find(params[:id])
     
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
     end
     
     y_axis = YAxis.new
     min_y_range = min([placed_orders, received_orders, inventory_histories])
     max_y_range = max([placed_orders, received_orders, inventory_histories])
     y_axis.set_range(min_y_range,max_y_range+100,100)
     
     chart = open_flash_chart(Title.new("统计图：游戏#{@role.game.name}，角色#{@role.name}"), create_x_axis(populate_x_label_values(@role.game)), y_axis)

     chart.add_element(create_placed_order_line(placed_orders))
     chart.add_element(create_received_order_line(received_orders))
     chart.add_element(create_inventory_history_line(inventory_histories))
     chart.add_element(create_cost_history_line(cost_histories))

     render :text => chart.to_s
   end

   private
   
   def populate_x_label_values game
     x_label_values = []
     (0..game.current_week-1).to_a.each do |week|
       x_label_values << (week).to_s
     end
     x_label_values
   end
   
   def data_of_roles
     (1..@game.roles.length-2).map{|role_index|
       data_of_role(role_index)
     }
   end

   def data_of_role role_index
     instance_variable_get("@#{@game.roles[role_index].english_name}")
   end
   
   def min(array_of_array)
     array_of_array.map{|array| array.min }.min rescue 0
   end
   
   def max(array_of_array)
     array_of_array.map{|array| array.max }.max rescue 0
   end
   
   def for_each_playable_role &block
     (1..@game.roles.length-2).each{ |role_index|
       yield role_index
     }
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
   
   def create_line text, color, values
     line = new_line
     line.text = text
     line.colour = color
     line.values = values
     line
   end
   
   def new_line
     line = Line.new
     line.width = 3
     line.dot_size = 1
     line
   end
end
