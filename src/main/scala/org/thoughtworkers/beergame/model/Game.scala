package org.thoughtworkers.beergame.model

import scala.collection.jcl.ArrayList

class Game(_name: String) {
	val name = _name

	private val _roles = new ArrayList[Role]()
	private var _currentWeek = 0
	
	def addRole(role: Role) {
		_roles.add(role)
		role.setGame(this)
	}
	
	def currentWeek = _currentWeek
	
	def passAWeek() {
		_currentWeek = _currentWeek + 1
	}
	
	def roleCount = _roles.size
}