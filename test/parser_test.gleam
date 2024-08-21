import file
import gleam/io
import gleeunit/should
import parser

pub fn inline_test() {
  let tests =
    parser.Document([
      parser.Paragraph([
        parser.Text("text"),
        parser.Emphasis([parser.Text("italic")]),
        parser.Strong([parser.Text("bold")]),
        parser.Sub([parser.Text("sub")]),
        parser.Super([parser.Text("super")]),
        parser.Text("end"),
      ]),
      parser.Paragraph([
        parser.Text("te xt"),
        parser.Emphasis([parser.Text("ita lic")]),
        parser.Strong([parser.Text("bo ld")]),
        parser.Sub([parser.Text("su b")]),
        parser.Super([parser.Text("sup er")]),
        parser.Text("end"),
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

pub fn nesting_test() {
  let tests =
    parser.Document([
      parser.Paragraph([
        parser.Text("normal text "),
        parser.Emphasis([
          parser.Text("this "),
          parser.Strong([
            parser.Text("is "),
            parser.Sub([parser.Text("properly")]),
          ]),
          parser.Text(" nested"),
        ]),
      ]),
      parser.Paragraph([
        parser.Emphasis([parser.Text("this is *italic")]),
        parser.Text(" this is not*"),
      ]),
      parser.Paragraph([
        parser.Strong([parser.Text("what _about ~double")]),
        parser.Text(" nesting?~_"),
      ]),
    ])

  case file.read("./test/nesting.djot") {
    Ok(input) -> {
      parser.parse(input)
      |> should.equal(tests)
    }
    Error(error) -> io.println_error(error)
  }
}
