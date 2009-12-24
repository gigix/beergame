package org.thoughtworkers.beergame.model

class Role(_name: String) {
	var _downstream: Role = null
	var _upstream: Role = null
	
	val name = _name
	
	def downstream = _downstream
	def upstream = _upstream
	
	def setUpstream(role: Role) {
		_upstream = role
		role.setDownstream(this)
	}
	
	private def setDownstream(role: Role) {
		_downstream = role
	}
}