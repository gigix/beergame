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
		game.name.set(name)
		
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
	
	// object done extends MappedBoolean(this) 
	// 	 object owner extends MappedLongForeignKey(this, User) 
	// 	 object priority extends MappedInt(this) { 
	// 	   override def defaultValue = 5 
	// 	 } 
	// 	 object desc extends MappedPoliteString(this, 128)
	
	object name extends MappedPoliteString(this, 128)
	object currentWeek extends MappedInt(this) {
		override def defaultValue = 0
	}
	
	private val _roles = new ArrayList[Role]()
	
	def addRole(role: Role) {
		_roles.add(role)
		role.setGame(this)
	}	
	
	def passAWeek {
		currentWeek.set(currentWeek + 1)
		for(role <- _roles) {
			role.update
		}
	}
	
	def roleCount = _roles.size		
}