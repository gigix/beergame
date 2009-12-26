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
		consumer.placeOrder(4)
		assertEquals(1, consumer.placedOrders.size)
		assertEquals(0, retailer.incomingOrders.size)
		assertEquals(12, consumer.inventory)
		assertEquals(12, retailer.inventory)
		
		game.passAWeek
		game.passAWeek
		assertEquals(1, retailer.incomingOrders.size)
		assertEquals(1, retailer.outgoingShips.size)
		assertEquals(0, consumer.incomingShips.size)
		
		val order = retailer.incomingOrders.first
		assertEquals(2, order.atWeek)
		assertEquals(4, order.amount)
		
		assertEquals(12, consumer.inventory)
		assertEquals(8, retailer.inventory)
		
		game.passAWeek
		game.passAWeek
		assertEquals(16, consumer.inventory)
		assertEquals(8, retailer.inventory)
		assertEquals(1, consumer.incomingShips.size)
	}
}
