package org.thoughtworkers.beergame.model

import _root_.junit.framework._
import Assert._

class GameTest extends TestCase("game") {
	val consumer = new Role("Consumer")
	val retailer = new Role("Retailer")
	val wholesaler = new Role("Wholesaler")
	val allRoles = Array(consumer, retailer, wholesaler)
	val game = new Game("Test Beer Game")
	
	override def setUp() {
		retailer.setUpstream(wholesaler)
		consumer.setUpstream(retailer)		
		
		for(role <- allRoles) {
			game.addRole(role)
		}
	}
	
	def test_create_game_with_roles() {
		assertEquals(3, game.roleCount)
		for(role <- allRoles) {
			assertEquals(game, role.game)
		}
	}
	
	def test_record_game_time() {
		assertEquals(0, retailer.currentWeek)
		game.passAWeek
		assertEquals(1, retailer.currentWeek)
	}
	
	def test_place_and_handle_order() {
		// TODO: write test here
	}
}
