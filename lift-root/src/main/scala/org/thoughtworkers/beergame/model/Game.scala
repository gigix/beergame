package org.thoughtworkers.beergame.model

import java.io.{File, FileOutputStream, FileInputStream, Serializable}
import scala.collection.jcl.ArrayList
import scala.util.Marshal

object Game {
	private val _allGames = new java.util.ArrayList[Game]()
	def all = new ArrayList[Game](_allGames)
	
	private val persistentDirName = "games"
	private val persistentDir = new File(persistentDirName)
	
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
	
	def load(name: String) = {
		val content = new Array[byte](dumpFile(name).length.intValue)
		val loadStream = new FileInputStream(dumpFile(name))
		loadStream.read(content)
		loadStream.close
		
		Marshal.load[Game](content)
	}
	
	private def dumpFile(name: String) = {
		val dumpFileName = name.split(" ").map(word => word.toLowerCase).deepMkString("_")
		new File(persistentDirName + File.separator + dumpFileName + ".dump")
	}	
}

@serializable 
class Game(_name: String) {
	val name = _name

	private val _roles = new java.util.ArrayList[Role]()
	private def roles = new ArrayList[Role](_roles)
	def roleCount = _roles.size		
	
	private var _currentWeek = 0
	
	def addRole(role: Role) {
		_roles.add(role)
		role.setGame(this)
	}
	
	def currentWeek = _currentWeek
	
	def passAWeek {
		_currentWeek = _currentWeek + 1
		for(role <- roles) {
			role.update
		}
	}
	
	def save {
		Game.persistentDir.mkdirs
		
		var dumpStream = new FileOutputStream(Game.dumpFile(name))
		dumpStream.write(Marshal.dump(this))
		dumpStream.close
	}
	
	override def equals(another: Any) = {
		if(another == null || !another.isInstanceOf[Game]) {
			false
		} else {
			another.asInstanceOf[Game].name == this.name
		}
	}
	
	override def hashCode = name.hashCode
}