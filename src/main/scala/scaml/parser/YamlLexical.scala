package scaml.parser

import scala.util.parsing.combinator.lexical.StdLexical
import scala.util.parsing.input.CharArrayReader.EofCh

class YamlLexical extends StdLexical with YamlTokens {

    override def token: Parser[Token] =
        (   '\n' ~> rep(whitespaceChar) ^^ { case chars => Indentation(chars mkString "")}
        |   repN(4,digit) ~ '-' ~ repN(2,digit) ~ '-' ~ repN(2,digit) ^^ {
                case year ~ _ ~ month ~ _ ~ day =>
                    DateLit(year ++ ('-' :: month) ++ ('-' :: day) mkString "")
            }
        |   opt('-') ~ rep1(digit) ~ '.' ~ rep(digit) ^^ {
                case Some(sign) ~ integer ~ _ ~ fraction =>
                    FloatLit(sign :: integer ++ ('.' :: fraction) mkString "")
                case None ~ integer ~ _ ~ fraction =>
                    FloatLit(integer ++ ('.' :: fraction) mkString "")
            }
        |   opt('-') ~ rep1(digit) ^^ {
                case Some(sign) ~ digits => NumericLit(sign :: digits mkString "")
                case None ~ digits => NumericLit(digits mkString "")}
        |   super.token
        )

    override def whitespace: Parser[Any] =
        rep(    whitespaceChar
            |   '#' ~ rep( chrExcept('\n'))
        )

    override def whitespaceChar = 
        elem("space char", ch => ch <= ' ' && ch != EofCh && ch != '\n')

}
