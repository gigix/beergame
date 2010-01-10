require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe GamesHelper do
  describe :link_to_play_a_role do
    before(:each) do
      @game = Game.create_with_roles('test_game', ['retailer', 'wholesaler', 'distributor', 'factory'])
      @consumer = @game.roles.first
      @retailer = @game.roles[1]
    end
    
    it 'generates link if role is playable' do
      helper.link_to_play_a_role(@retailer).should =~ /a href.+/
    end
    
    it 'does not generate link if role is not playable' do
      helper.link_to_play_a_role(@consumer).should_not =~ /a href.+/
    end
  end
end
