package org.thoughtworkers.beergame.model

import net.liftweb._ 
import mapper._ 

object Order extends Order with LongKeyedMetaMapper[Order] {
	def build(atWeek:Int, amount:Int) = {
		val order = new Order()
		order.setAtWeek(atWeek)
		order.setAmount(amount)
		order
	}
}

class Order extends LongKeyedMapper[Order] with IdPK {
	def getSingleton = Order

	private var _atWeek:Int = 0
	def atWeek = _atWeek
	def setAtWeek(atWeek:Int) {
		_atWeek = atWeek
	}

	private var _amount:Int = 0	
	def amount = _amount
	def setAmount(amount:Int) {
		_amount = amount
	}
}