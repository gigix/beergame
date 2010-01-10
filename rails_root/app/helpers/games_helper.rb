module GamesHelper
  def link_to_play_a_role(role)
    return role.name unless role.playable?
    link_to role.name, game_role_path(role.game, role)
  end
end
