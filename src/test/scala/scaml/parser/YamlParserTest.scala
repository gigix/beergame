/*
 * ParserTest.scala
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

package scaml.parser

import org.junit.After
import org.junit.Before
import org.junit.Test
import org.junit.Ignore
import org.junit.Assert._

import scaml.representation._

import java.util.Date

class YamlParserTest {

    @Ignore
    @Test
    def testComments() = {
        println(">>>>> testComments")

        val result = YamlParser.doMatch(
            "---\nabc # sdhsfasf kashfagfjhagfjh\ndef\nghi\n...\n--- # iuashfjhasfhashjfgjagf\ndef")

        println(result)

        assertEquals(2, result.size)
        assertEquals(StringNode("abc def ghi"), result(0))
        assertEquals(StringNode("def"), result(1))
    }

    @Ignore
    @Test
    def documentsWithListsTest() = {
        println(">>>>> documentsWithListsTest")

        val result = YamlParser.doMatch(
            "---\nabc nyo\nghi\n...\n---\n- def\n- ghi")

        println(result)
        
        assertEquals(2, result.size)
        assertEquals(StringNode("abc nyo ghi"), result(0))
        assertEquals(
            ListElement(List(
                StringNode("def"), StringNode("ghi")
            )),
            result(1))
    }

    @Ignore
    @Test
    def documentsWithSerializedListsTest() = {
        println(">>>>> documentsWithSerializedListsTest")

        val result = YamlParser.doMatch(
            "---\nabc def\nghi\n...\n---\n[def,ghi]")

        println(result)

        assertEquals(2, result.size)
        assertEquals(StringNode("abc def ghi"), result(0))
        assertEquals(
            ListElement(List(
                StringNode("def"), StringNode("ghi")
            )),
            result(1))
    }

    @Test
    def documentWithSerializedMultilevelList() = {
        println(">>>>> documentWithSerializedMultilevelList")
        
        val result = YamlParser.doMatch("[[abc,def],[ghi,jkl]]")

        println(result)

        assertEquals(1, result.size)
        assertEquals(
            ListElement(List(
                ListElement(List(
                    StringNode("abc"), StringNode("def"))),
                ListElement(List(
                    StringNode("ghi"), StringNode("jkl"))))),
            result(0))
    }

    @Test
    def documentWithMultilevelList() = {
        println(">>>>> documentWithMultilevelList")

        val result = YamlParser.doMatch(
            "- \n    - abc\n    - def\n- \n    - ghi\n    - jkl")

        println(result)

        assertEquals(1, result.size)
        assertEquals(
            ListElement(List(
                ListElement(List(
                    StringNode("abc"), StringNode("def"))),
                ListElement(List(
                    StringNode("ghi"), StringNode("jkl"))))),
            result(0))
    }

    @Test
    def testIntegers() = {
        println(">>>>> testInegers")
        val result = YamlParser.doMatch("12345\n---\n-2345")

        println(result)

        assertEquals(2, result.size)
        assertEquals(
            List(IntegerNode(12345), IntegerNode(-2345)),
            result)
    }

    @Test
    def testFloats() = {
        println(">>>>> testFloats")
        val result = YamlParser.doMatch("12.345\n---\n-2.345")

        println(result)

        assertEquals(2, result.size)
        assertEquals(
            List(FloatNode(12.345f), FloatNode(-2.345f)),
            result)
    }

    @Test
    def testBooleansAndNull() = {
        println(">>>>> testBooleansAndNull")
        val result = YamlParser.doMatch("y\n---\nn\n---\n~")

        println(result)

        assertEquals(3, result.size)
        assertEquals(
            List(BooleanNode(true), BooleanNode(false), NullNode()),
            result)
    }

    @Test
    def testDate() = {
        println(">>>>> testDate")
        val result = YamlParser.doMatch("2009-01-01\n---\n2001-11-12")

        println(result)

        assertEquals(2, result.size)
        assertEquals(
            List(DateNode(new Date(2009, 1, 1)), DateNode(new Date(2001, 11, 12))),
            result)
    }

    @Test
    def testSerializedMap() = {
        println(">>>>> testSerializedMap")
        val result = YamlParser.doMatch("{ one : 1, two : 2}")

        println(result)

        assertEquals(1, result.size)
        assertEquals(
            List(MapElement(
                    Map(
                        StringNode("one") -> IntegerNode(1),
                        StringNode("two") -> IntegerNode(2)
                    )
            )),
            result)
    }

    @Test
    def testSimpleMap() = {
        println(">>>>> testSimpleMap")
        val result = YamlParser.doMatch("one : 1\ntwo : 2")

        println(result)

        assertEquals(1, result.size)
        assertEquals(
            List(MapElement(
                    Map(
                        StringNode("one") -> IntegerNode(1),
                        StringNode("two") -> IntegerNode(2)
                    )
            )),
            result)
    }

    @Test
    def testMultiMap() = {
        println(">>>>> testMultiMap")
        val result = YamlParser.doMatch("one :\n  one1 : 11\n  one2 : 12")

        println(result)

        assertEquals(1, result.size)
        assertEquals(
            List(MapElement(
                    Map(
                        StringNode("one") ->
                            MapElement(
                                Map(
                                    StringNode("one1") -> IntegerNode(11),
                                    StringNode("one2") -> IntegerNode(12)
                                )
                            )
                    )
            )),
            result)
    }

    @Test
    def testStrTag() = {
        println(">>>>> testStrTag")
        val result = YamlParser.doMatch("!!str 11\n---\n!!str 2009-01-01\n---\n!!str y\n---\n!!str ~")

        println(result)

        assertEquals(4, result.size)
        assertEquals(
            List(
                StringNode("11"),
                StringNode("2009-01-01"),
                StringNode("y"),
                StringNode("~")
            ),
            result)
    }

}
