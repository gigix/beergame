package org.thoughtworkers.beergame.model

import _root_.java.io.File
import _root_.junit.framework._
import Assert._

class RoleTest extends TestCase("role") {
	def test_create_role_with_name() {
		var retailer = new Role("Retailer")
		assertTrue(retailer != Nil)
		assertEquals("Retailer", retailer.name)
	}
}
