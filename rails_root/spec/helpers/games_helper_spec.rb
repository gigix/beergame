require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe GamesHelper do
  include PreparedGame
  
  describe :link_to_play_a_role do
    it 'generates link if role is playable' do
      helper.link_to_play_a_role(@retailer).should =~ /a href.+/
    end
    
    it 'does not generate link if role is not playable' do
      helper.link_to_play_a_role(@consumer).should_not =~ /a href.+/
    end
  end
end
