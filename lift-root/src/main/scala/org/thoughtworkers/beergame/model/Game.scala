package org.thoughtworkers.beergame.model

import java.io.File
import scala.collection.jcl.ArrayList

object Game {
	private val _allGames = new ArrayList[Game]()
	
	def all = _allGames
	
	def build(name: String, playerRoleNames: Array[String]) = {
		val game = new Game(name)
		
		val consumer = new Role("Consumer")		
		game.addRole(consumer)
		
		var currentRole = consumer
		for(roleName <- playerRoleNames) {
			val role = new Role(roleName)
			game.addRole(role)			
			currentRole.setUpstream(role)
			currentRole = role
		}
		
		val brewery = new Role("Brewery", 1, 1)
		brewery.setInventory(Math.POS_INF_FLOAT.toInt)
		currentRole.setUpstream(brewery)
		game.addRole(brewery)
		
		_allGames.add(game)
		game
	}
}

class Game(_name: String) {
	val name = _name

	private val _roles = new ArrayList[Role]()
	private var _currentWeek = 0
	
	def addRole(role: Role) {
		_roles.add(role)
		role.setGame(this)
	}
	
	def currentWeek = _currentWeek
	
	def passAWeek {
		_currentWeek = _currentWeek + 1
		for(role <- _roles) {
			role.update
		}
	}
	
	def roleCount = _roles.size		
}