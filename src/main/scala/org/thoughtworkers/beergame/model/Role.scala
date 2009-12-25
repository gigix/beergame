package org.thoughtworkers.beergame.model

class Role(_name: String) {
	private var _downstream: Role = null
	private var _upstream: Role = null
	private var _game: Game = null
	
	val name = _name
	
	def downstream = _downstream
	def upstream = _upstream
	def game = _game
	def currentWeek = _game.currentWeek
	
	def setUpstream(role: Role) {
		_upstream = role
		role.setDownstream(this)
	}
	
	def setGame(game: Game) {
		_game = game
	}
	
	private def setDownstream(role: Role) {
		_downstream = role
	}
}