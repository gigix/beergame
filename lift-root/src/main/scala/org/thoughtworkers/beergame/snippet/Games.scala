package org.thoughtworkers.beergame.snippet

import _root_.scala.xml.{NodeSeq,Text,Node,Elem}
import _root_.net.liftweb.util.{Box,Full,Empty,Helpers,Log}
import _root_.net.liftweb.util.Helpers._
import _root_.net.liftweb.http.{S,SHtml}

import org.thoughtworkers.beergame.model.Game

class Games {
	def list: NodeSeq = <ul>{
			Game.all.map{game => <li>{game.name}</li>}
		}</ul>
		
	def create(xhtml : NodeSeq) : NodeSeq = {
		var name = ""
		
		def processEntry () = {
			val playerRoles = Array("Retailer", "Wholesaler", "Distributor", "Factory")
		    val game = Game.build(name, playerRoles)
			game.save
			// S.notice("Entry is " + name)
		}
		
		bind("game", xhtml,
			"name" -> SHtml.text(name, name = _),
			"submit" -> SHtml.submit("创建", processEntry))
	}
}