package org.thoughtworkers.beergame.model

import net.liftweb._ 
import mapper._ 

import scala.collection.jcl.ArrayList

object Role extends Role with LongKeyedMetaMapper[Role] {
	def build(name: String, informationDelay: Int, shippingDelay: Int) = {
		val role = new Role()
		role.name.set(name)
		role.informationDelay.set(informationDelay)
		role.shippingDelay.set(shippingDelay)
		role
	}
	
	def build(name: String): Role = build(name, 2, 2)
}

class Role extends LongKeyedMapper[Role] with IdPK {
	def getSingleton = Role
	
	// object done extends MappedBoolean(this) 
	// 	 object owner extends MappedLongForeignKey(this, User) 
	
	object name extends MappedPoliteString(this, 128)
	object informationDelay extends MappedInt(this)	
	object shippingDelay extends MappedInt(this)
	object inventory extends MappedInt(this) {
		override def defaultValue = 12
	}
	
	object hasPlacedOrder extends MappedBoolean(this)
	def hasPlacedOrder_? = hasPlacedOrder.is

	// object game extends MappedLongForeignKey(this, Game)
	private var _game: Game = null
	def game = _game
	
	private var _downstream: Role = null
	private var _upstream: Role = null
	
	private val _inbox = new ArrayList[Order]
	private val _logistics = new ArrayList[Order]
	
	private val _placedOrders = new ArrayList[Order]
	private val _incomingOrders = new ArrayList[Order]
	private val _outgoingShips = new ArrayList[Order]
	private val _incomingShips = new ArrayList[Order]
	
	def downstream = _downstream
	def upstream = _upstream
	
	def currentWeek = {
		if(_game == null) {
			null
		} else {
			_game.currentWeek
		}
	}
	
	def setUpstream(role: Role) {
		_upstream = role
		role.setDownstream(this)
	}
	
	def setGame(game: Game) {
		_game = game
	}
	
	def update {
		hasPlacedOrder.set(false)
		
		for(order <- _inbox.clone) {
			if(order.atWeek == currentWeek - informationDelay.is) {
				handleIncomingOrder(order)
			}
		}
		
		for(ship <- _logistics.clone) {
			if(ship.atWeek == currentWeek - shippingDelay.is) {
				handleIncomingShip(ship)
			}
		}
	}
	
	def placeOrder(amount: Int) {
		if(hasPlacedOrder_?) {
			return
		}
		
		val placedOrder = Order.build(currentWeek, amount)
		_placedOrders.add(placedOrder)
		_upstream._inbox.add(placedOrder)
		
		hasPlacedOrder.set(true)
	}
	
	def placedOrders = _placedOrders.clone
	def incomingOrders = _incomingOrders.clone
	def outgoingShips = _outgoingShips.clone
	def incomingShips = _incomingShips.clone
	
	private def setDownstream(role: Role) {
		_downstream = role
	}
	
	private def handleIncomingOrder(order: Order) {
		val incomingOrder = Order.build(currentWeek, order.amount)
		_incomingOrders.add(incomingOrder)
		_inbox.remove(order)
		
		val requestedAmount = incomingOrder.amount
		var shippedAmount = requestedAmount
		if(inventory.is < requestedAmount) {
			shippedAmount = inventory.is
		}
		inventory.set(inventory - requestedAmount)

		val shippedOrder = Order.build(currentWeek, shippedAmount)
		_outgoingShips.add(shippedOrder)			
		_downstream._logistics.add(shippedOrder)
	}
	
	private def handleIncomingShip(ship: Order) {
		inventory.set(inventory + ship.amount)
		_incomingShips.add(ship)
		_logistics.remove(ship)
	}
}