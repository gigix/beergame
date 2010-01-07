package scaml.parser

import scala.util.parsing.combinator.syntactical.StdTokenParsers
import scala.util.parsing.syntax.StdTokens

import scaml.representation._

import java.util.Date

object YamlParser extends StdTokenParsers with YamlTokens{
    type Tokens = YamlTokens
    val lexical = new YamlLexical

    lexical.delimiters ++= List("---", "...", "-", "[", "]", ",", "~", "{", "}", ":", "!!str")
    lexical.reserved ++= List("y", "n")

    /*
     * entry point and preamble
     */

    /*
     * structure
     */

    def stream = phrase(
            opt(opt(indentation) ~ "---") ~> repsep(document, indentation ~ "---")
        )

    def indentation =
        elem("indentation", _.isInstanceOf[Indentation]) ^^ (_.chars.length)

    def exact_indentation(i : Int) =
        elem("exact " + i + " indentation",
             (e : Elem) => e.isInstanceOf[Indentation] && e.chars.length == i) ^^
                {_.chars.length}

    def floatLit = elem("float literal", _.isInstanceOf[FloatLit]) ^^ {_.chars}

    def dateLit = elem("date literal", _.isInstanceOf[DateLit]) ^^ {_.chars}

    /*
     * document related
     */

    def document =
        opt(element) <~ opt(indentation ~ "...") ^^
        {   case Some(e)    => e
            case None       => EmptyElement() }

    def element = list_element | map_element | opt(indentation) ~> node_element

    /*
     * literals
     */

    def node_element = 
        (   "!!str" ~> (dateLit | numericLit | floatLit | "y" | "n" | "~") ^^ {
                StringNode(_)
            }
        |   dateLit ^^ {
                case d =>
                    val elements = d.split("-").map(e => e.toInt)
                    DateNode(new Date(elements(0), elements(1), elements(2)))
            }
        |   numericLit ^^ { case n => IntegerNode(n.toInt) }
        |   floatLit ^^ { case f => FloatNode(f.toFloat)}
        |   ("y" | "n") ^^ {
               case "y" => BooleanNode(true)
               case "n" => BooleanNode(false)
            }
        |   "~" ^^^ {NullNode()}
        |   string_node
        )

    // TODO need to find a way to handle both types of string node
    def string_node = rep(ident) ^^ //repsep(ident, opt(indentation)) ^^
        { case s => new StringNode(
            s.foldLeft("") { (a,b) => a match {
                case "" => b
                case _ => a + " " + b}})
        }

    /*
     * list related
     */

    def list_element : Parser[Element] =
        (   indented_list 
        |   opt(indentation) ~ "[" ~> repsep(serialized_list_item, ",") <~ "]"
        ) ^^ {ListElement(_)}

    def indented_list = first_list_item >> next_list_items

    def list_item = "-" ~> element

    def first_list_item = opt(indentation) ~ list_item ^^ {
        case Some(i) ~ e    => (i,e)
        case None ~ e       => (0,e)
    }

    def indented_list_item(i:Int)  = exact_indentation(i) ~> list_item

    def next_list_items(left:(Int,Element)) =
        rep(indented_list_item(left._1)) ^^ { left._2 :: _ }

    def serialized_list_item = opt(indentation) ~> element

    /*
     * map related
     */

    def map_element =
        (   opt(indentation) ~ "{" ~> repsep(serialized_map_item, ",") <~ "}"
        |   indented_map 
        ) ^^ { case l =>  MapElement(Map.empty[Element,Element] ++ l) }

    def indented_map = first_map_item >> next_map_items

    def first_map_item : Parser[(Int,(Element,Element))] =
        opt(indentation) ~ map_item ^^ {
                case Some(i) ~ e    => (i,e)
                case None ~ e       => (0,e)
            }
            
    def map_item : Parser[(Element,Element)] =
        node_element ~ ":" ~ element ^^ { case key ~ _ ~ value => (key, value)}

    def next_map_items(left : (Int,(Element,Element))) =
        rep(indented_map_item(left._1)) ^^ {left._2 :: _}

    def indented_map_item(i : Int) = exact_indentation(i) ~> map_item

    def serialized_map_item = opt(indentation) ~> map_item

    /*
     * others
     */
    
    def doMatch(input : String) = {
        stream(new lexical.Scanner(input)) match {
            case Success(result, _) => result
            case Failure(msg, desc) => throw new Exception(
                    "Failure " + msg + ". Offset:" + desc.offset + " POS:" + desc.pos)
            case Error(msg, desc)   => throw new Exception(
                    "Error " + msg + ". Offset:" + desc.offset + " POS:" + desc.pos)
        }
    }

}
