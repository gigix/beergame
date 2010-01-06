package org.thoughtworkers.beergame.model

import _root_.junit.framework._
import Assert._

class RoleTest extends TestCase("role") {
	val retailer = Role.build("Retailer")
	val consumer = Role.build("Consumer")
	val wholesaler = Role.build("Wholesaler")
	
	override def setUp() {
		retailer.setUpstream(wholesaler)
		consumer.setUpstream(retailer)		
	}
	
	def test_create_role_with_name() {
		val retailer = Role.build("Retailer")
		assertTrue(retailer != null)
		assertEquals("Retailer", retailer.name.is)
	}
	
	def test_associate_downstream_and_upstream_roles() {
		assertEquals(retailer.downstream, consumer)
		assertEquals(retailer.upstream, wholesaler)
		
		assertEquals(consumer.upstream, retailer)
		assertEquals(wholesaler.downstream, retailer)
	}
}
