package org.thoughtworkers.beergame.model

import scala.collection.jcl.ArrayList

class Role(_name: String) {
	val name = _name
	private val informationDelay = 2
	private val shippingDelay = 2
	
	private var _game: Game = null
	private var _downstream: Role = null
	private var _upstream: Role = null
	
	private var _inventory = 12
	
	private val _inbox = new ArrayList[Order]
	private val _logistics = new ArrayList[Order]
	
	private val _placedOrders = new ArrayList[Order]
	private val _incomingOrders = new ArrayList[Order]
	private val _outgoingShips = new ArrayList[Order]
	private val _incomingShips = new ArrayList[Order]
	
	def downstream = _downstream
	def upstream = _upstream
	def game = _game
	def currentWeek = _game.currentWeek
	def inventory = _inventory
	
	def setUpstream(role: Role) {
		_upstream = role
		role.setDownstream(this)
	}
	
	def setGame(game: Game) {
		_game = game
	}
	
	def update {
		for(order <- _inbox.clone) {
			if(order.atWeek == currentWeek - informationDelay) {
				handleIncomingOrder(order)
			}
		}
		
		for(ship <- _logistics.clone) {
			if(ship.atWeek == currentWeek - shippingDelay) {
				handleIncomingShip(ship)
			}
		}
	}
	
	def placeOrder(amount: Int) {
		val placedOrder = new Order(currentWeek, amount)
		_placedOrders.add(placedOrder)
		_upstream.receiveOrder(placedOrder)
	}
	
	def placedOrders = _placedOrders.clone
	def incomingOrders = _incomingOrders.clone
	def outgoingShips = _outgoingShips.clone
	def incomingShips = _incomingShips.clone
	
	private def setDownstream(role: Role) {
		_downstream = role
	}
	
	private def receiveOrder(order: Order) {
		_inbox.add(order)
	}
	
	private def handleIncomingOrder(order: Order) {
		val incomingOrder = new Order(currentWeek, order.amount)
		_incomingOrders.add(incomingOrder)
		_inbox.remove(order)
		
		val requestedAmount = incomingOrder.amount
		var shippedAmount = requestedAmount
		if(_inventory < requestedAmount) {
			shippedAmount = _inventory
		}
		_inventory -= requestedAmount				

		val shippedOrder = new Order(currentWeek, shippedAmount)
		_outgoingShips.add(shippedOrder)			
		_downstream._logistics.add(shippedOrder)
	}
	
	private def handleIncomingShip(ship: Order) {
		_inventory += ship.amount
		_incomingShips.add(ship)
		_logistics.remove(ship)
	}
}