package org.thoughtworkers.beergame.model

import _root_.java.io.File
import _root_.junit.framework._
import Assert._

class RoleTest extends TestCase("role") {
	def test_create_role_with_name() {
		var retailer = new Role("Retailer")
		assertTrue(retailer != null)
		assertEquals("Retailer", retailer.name)
	}
	
	def test_associate_downstream_and_upstream_roles() {
		var retailer = new Role("Retailer")
		var consumer = new Role("Consumer")
		var wholesaler = new Role("Wholesaler")
		
		retailer.setUpstream(wholesaler)
		consumer.setUpstream(retailer)
		
		assertEquals(retailer.downstream, consumer)
		assertEquals(retailer.upstream, wholesaler)
		
		assertEquals(consumer.upstream, retailer)
		assertEquals(wholesaler.downstream, retailer)
	}
}
