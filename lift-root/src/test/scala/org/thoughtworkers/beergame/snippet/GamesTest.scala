package org.thoughtworkers.beergame.snippet

import _root_.junit.framework._
import Assert._

import net.liftweb.http.{S, LiftSession}
import net.liftweb.util._

import scala.collection.jcl.ArrayList

class GamesTest extends TestCase {
	def test_create_game() {
		val session : LiftSession = new LiftSession("", StringHelpers.randomString(20), null, null)
		S.initIfUninitted(session) {
			val xml = 
				<lift:games.create form='post'>
					<p>Name:<game:name /></p>
					<p><game:submit /></p>
				</lift:games.create>
			
			val snippet = new Games
			val output = snippet.create(xml)
			assertNotNull(output)
		}
	}
}