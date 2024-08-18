import file
import gleam/io
import gleeunit/should
import lexer
import parser

pub fn parser_test() {
  let tests =
    parser.Document([
      parser.Paragraph([
        parser.Emphasis([parser.Text("this is *a")]),
        parser.Sub([parser.Text("message")]),
        parser.Text("*"),
      ]),
      parser.Paragraph([
        parser.Text("_this is"),
        parser.Strong([parser.Text("a "), parser.Sub([parser.Text("message")])]),
      ]),
    ])

  case file.read("./test/parser.djot") {
    Ok(input) -> {
      lexer.new(input)
      |> parser.parse()
      |> should.equal(tests)
    }
    Error(error) -> io.println_error(error)
  }
}
