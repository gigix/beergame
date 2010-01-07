package scaml.representation

import java.util.Date

sealed abstract class Element;

// TODO make value abstract
abstract case class NodeElement() extends Element;

    case class StringNode(value : String) extends NodeElement;

    case class IntegerNode(value : Int) extends NodeElement;

    case class FloatNode(value : Float) extends NodeElement;

    case class DateNode(value : Date) extends NodeElement;

    case class BooleanNode(value : Boolean) extends NodeElement;

    case class NullNode() extends NodeElement;

case class ListElement(value : List[Element]) extends Element;

case class MapElement(value : Map[Element,Element]) extends Element;

case class EmptyElement() extends Element;