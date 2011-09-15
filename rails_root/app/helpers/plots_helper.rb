module PlotsHelper
  def plot_title(method_type)
    title_hash = { 
      "placed_orders" => "订货量", 
      "received_orders" => "需求量",
      "inventory_histories" => "库存量",
      "cost_histories" => "成本"
    }
    title_hash[method_type]
  end
  
  def link_to_team_plot(method_type)
    title = plot_title(method_type)
    link_to "查看#{title}统计图表", 
      {:controller => "plots", :action => "show_team_plot", :id => @game, :method_type => method_type}, 
      :rel => "gb_page_center[1100, 700]"
  end
end
