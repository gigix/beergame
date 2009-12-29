package org.thoughtworkers.beergame.model

import scala.collection.jcl.ArrayList

class Role(_name: String, _informationDelay: Int, _shippingDelay: Int) {
	def this(name: String) {
		this(name, 2, 2)
	}
	
	val name = _name
	private val informationDelay = _informationDelay
	private val shippingDelay = _shippingDelay
	
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
	
	private var _hasPlacedOrder = false
	
	def downstream = _downstream
	def upstream = _upstream
	def game = _game
	def currentWeek = _game.currentWeek
	def inventory = _inventory
	def hasPlacedOrder = _hasPlacedOrder
	
	def setUpstream(role: Role) {
		_upstream = role
		role.setDownstream(this)
	}
	
	def setGame(game: Game) {
		_game = game
	}
	
	def setInventory(inventory: Int) {
		_inventory = inventory
	}
	
	def update {
		_hasPlacedOrder = false
		
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
		if(hasPlacedOrder) {
			return
		}
		
		val placedOrder = new Order(currentWeek, amount)
		_placedOrders.add(placedOrder)
		_upstream._inbox.add(placedOrder)
		
		_hasPlacedOrder = true
	}
	
	def placedOrders = _placedOrders.clone
	def incomingOrders = _incomingOrders.clone
	def outgoingShips = _outgoingShips.clone
	def incomingShips = _incomingShips.clone
	
	private def setDownstream(role: Role) {
		_downstream = role
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