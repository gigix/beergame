package org.thoughtworkers.beergame.model

@serializable
class Order(_atWeek: Int, _amount: Int) {
	val atWeek = _atWeek
	val amount = _amount
}