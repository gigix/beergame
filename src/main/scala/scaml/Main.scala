package scaml

import java.io.{File, ByteArrayOutputStream, FileInputStream}

import scaml.parser.YamlParser
import scaml.representation._

object Main {

    /**
     * @param args the command line arguments
     */
    def main(args: Array[String]) : Unit = {
        if (args.size == 0) {
            println ("No file specified")
            return
        }

        val file = new File(args(0))

        if (!file.exists) {
            println("File " + args(0) + " doesn't exist")
            return
        }

        val content = readFile(file)

        val result = YamlParser.doMatch(content)

        printResult(result);
    };

    def readFile(f : File) = {
        val bos = new ByteArrayOutputStream
        val ba = new Array[Byte](1024)
        val is = new FileInputStream(f)

        def read {
            is.read(ba) match {
                case n if n < 0 =>
                case 0 => read
                case n => bos.write(ba, 0, n)
            }
        }

        read
        bos.toString
    }

    def printResult(result : List[Element]) = {

        def printElement(e : Element, i : Int) : Unit = {
            e match {
                case elem if elem.isInstanceOf[ListElement] =>
                    printIndented("List:", i)
                    for (inner <- elem.asInstanceOf[ListElement].value)
                        printElement(inner, i + 1)
                case elem if elem.isInstanceOf[MapElement] =>
                    printIndented("Map:", i)
                    for (inner <- elem.asInstanceOf[MapElement].value) {
                        printElement(inner._1, i + 1)
                        printIndented("->", i + 1)
                        printElement(inner._2, i + 2)
                    }
                case elem if elem.isInstanceOf[EmptyElement] => {printIndented("()", i)}
                case elem => {
                    printIndented(elem.asInstanceOf[NodeElement].toString, i)
                }
            }
        }

        def printIndented(s :String, n : Int) = {
            for (i <- 0 until n) print('\t')
            println(s)
        }

        for (e <- result) {
            printElement(e, 0)
            println("----------------------------------------------")
        }
    }

}
