package org.thoughtworkers.beergame.snippet

import _root_.scala.xml._
import org.thoughtworkers.beergame.model.Game

class Games {
	def list: NodeSeq = <ul>{Game.all}</ul>
}