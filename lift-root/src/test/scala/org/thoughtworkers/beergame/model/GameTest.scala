package org.thoughtworkers.beergame.model

import _root_.junit.framework._
import Assert._

class GameTest extends TestCase("game") {
	val consumer = Role.build("Consumer")
	val retailer = Role.build("Retailer")
	val wholesaler = Role.build("Wholesaler")
	val allRoles = Array(consumer, retailer, wholesaler)
	val game = new Game
	
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
		assertEquals(0, retailer.currentWeek.is)
		game.passAWeek
		assertEquals(1, retailer.currentWeek.is)
	}
	
	def test_place_and_handle_order() {
		consumer.placeOrder(4)
		assertEquals(1, consumer.placedOrders.size)
		assertEquals(0, retailer.incomingOrders.size)
		assertEquals(12, consumer.inventory.is)
		assertEquals(12, retailer.inventory.is)
		
		game.passAWeek
		game.passAWeek
		assertEquals(1, retailer.incomingOrders.size)
		assertEquals(1, retailer.outgoingShips.size)
		assertEquals(0, consumer.incomingShips.size)
		
		val order = retailer.incomingOrders.first
		assertEquals(2, order.atWeek)
		assertEquals(4, order.amount)
		
		assertEquals(12, consumer.inventory.is)
		assertEquals(8, retailer.inventory.is)
		
		game.passAWeek
		game.passAWeek
		assertEquals(16, consumer.inventory.is)
		assertEquals(8, retailer.inventory.is)
		assertEquals(1, consumer.incomingShips.size)
	}
	
	def test_build_a_standard_game() {
		val playerRoles = Array("Retailer", "Wholesaler", "Distributor", "Factory")
		val game = Game.build("A Standard Game", playerRoles)
		
		assertEquals("A Standard Game", game.name.is)
		assertEquals(6, game.roleCount)
	}
	
	def test_each_role_can_place_order_only_once_per_week() {
		consumer.placeOrder(4)
		assert(consumer.hasPlacedOrder)
		consumer.placeOrder(4)
		assertEquals(1, consumer.placedOrders.size)
		assertEquals(4, consumer.placedOrders.first.amount)
		
		game.passAWeek
		consumer.placeOrder(4)
		assertEquals(2, consumer.placedOrders.size)
	}	
	
	def test_list_all_games() {
		assertEquals(0, Game.all.size)
		Game.build("A Standard Game", Array("Retailer", "Wholesaler", "Distributor", "Factory"))
		assertEquals(1, Game.all.size)
	}	
}
