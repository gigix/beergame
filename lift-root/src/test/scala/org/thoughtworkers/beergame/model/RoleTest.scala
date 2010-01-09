package org.thoughtworkers.beergame.model

import _root_.junit.framework._
import Assert._

import scala.util.Marshal

class RoleTest extends TestCase("role") {
	val retailer = new Role("Retailer")
	val consumer = new Role("Consumer")
	val wholesaler = new Role("Wholesaler")
	
	override def setUp() {
		retailer.setUpstream(wholesaler)
		consumer.setUpstream(retailer)		
	}
	
	def test_create_role_with_name() {
		val retailer = new Role("Retailer")
		assertTrue(retailer != null)
		assertEquals("Retailer", retailer.name)
	}
	
	def test_associate_downstream_and_upstream_roles() {
		assertEquals(retailer.downstream, consumer)
		assertEquals(retailer.upstream, wholesaler)
		
		assertEquals(consumer.upstream, retailer)
		assertEquals(wholesaler.downstream, retailer)
	}
	
	def test_serialization() {
		consumer.placeOrder(4)
		val serializedBytes = Marshal.dump(consumer)
		val loadedConsumer = Marshal.load[Role](serializedBytes)
		
		// assertEquals(consumer, loadedConsumer)
		assertEquals(1, loadedConsumer.placedOrders.size)
		assertEquals(4, loadedConsumer.placedOrders.first.amount)
	}
}
