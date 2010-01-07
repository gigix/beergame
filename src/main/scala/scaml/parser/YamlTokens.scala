package scaml.parser

import scala.util.parsing.syntax.StdTokens

trait YamlTokens extends StdTokens {

    case class Indentation(chars: String) extends Token {
        override def toString = chars
    }

    case class FloatLit(chars: String) extends Token {
        override def toString = chars
    }

    case class DateLit(chars: String) extends Token {
        override def toString = chars
    }

}
