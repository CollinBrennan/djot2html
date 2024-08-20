import file
import gleam/io
import gleeunit/should
import parser

pub fn parser_test() {
  let tests =
    parser.Document([
      parser.Paragraph([
        parser.Emphasis([parser.Text("italic")]),
        parser.Strong([parser.Text("bold")]),
        parser.Sub([parser.Text("sub")]),
        parser.Super([parser.Text("super")]),
      ]),
      parser.Paragraph([
        parser.Emphasis([parser.Text("ita lic")]),
        parser.Strong([parser.Text("bo ld")]),
        parser.Sub([parser.Text("su b")]),
        parser.Super([parser.Text("sup er")]),
      ]),
    ])

  case file.read("./test/test.djot") {
    Ok(input) -> {
      parser.parse(input)
      |> should.equal(tests)
    }
    Error(error) -> io.println_error(error)
  }
}

pub fn paragraph_test() {
  let tests =
    parser.Document([
      parser.Paragraph([
        parser.Text("this is a paragraph! this is still a paragraph!"),
      ]),
      parser.Paragraph([parser.Text("this is a different paragraph!")]),
    ])

  case file.read("./test/paragraph.djot") {
    Ok(input) -> {
      parser.parse(input)
      |> should.equal(tests)
    }
    Error(error) -> io.println_error(error)
  }
}
