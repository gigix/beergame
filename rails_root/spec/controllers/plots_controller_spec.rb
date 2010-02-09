require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PlotsController do
  integrate_views
  
  include PreparedGame
  
  describe 'GET show' do
    it 'renders with given role' do
      get :show, :id => @retailer
      response.should be_success 
    end
  end
end
