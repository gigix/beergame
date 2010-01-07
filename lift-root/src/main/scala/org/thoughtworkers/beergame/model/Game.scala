package org.thoughtworkers.beergame.model

import net.liftweb._ 
import mapper._ 

import java.io.File
import scala.collection.jcl.ArrayList

object Game extends Game with LongKeyedMetaMapper[Game] {
	private val _allGames = new ArrayList[Game]()
	
	def all = _allGames
	
	def build(name: String, playerRoleNames: Array[String]) = {
		val game = new Game
		game.setName(name)
		
		val consumer = Role.build("Consumer")		
		game.addRole(consumer)
		
		var currentRole = consumer
		for(roleName <- playerRoleNames) {
			val role = Role.build(roleName)
			game.addRole(role)			
			currentRole.setUpstream(role)
			currentRole = role
		}
		
		val brewery = Role.build("Brewery", 1, 1)
		brewery.setInventory(Math.POS_INF_FLOAT.toInt)
		currentRole.setUpstream(brewery)
		game.addRole(brewery)
		
		_allGames.add(game)
		game
	}
}

class Game extends LongKeyedMapper[Game] with IdPK {
	def getSingleton = Game
	
	private var _name: String = null
	def name = _name
	def setName(name: String) {
		_name = name
	}

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