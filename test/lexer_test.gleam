import file
import gleam/io
import gleam/option.{Some}
import gleeunit/should
import lexer
import token

pub fn lexer_test() {
  let tests = [
    token.Underscore,
    token.Text("italic"),
    token.Underscore,
    token.Text(" "),
    token.Star,
    token.Text("bold"),
    token.Star,
    token.NewLine,
  ]

  case file.read("./test/test.djot") {
    Ok(text) -> assert_tokens_equal(lexer.new(text), tests)
    Error(error) -> io.println_error(error)
  }
}

fn assert_tokens_equal(l: lexer.Lexer, tests: List(token.Token)) {
  case tests {
    [] -> Nil
    [first, ..rest] -> {
      should.equal(l.current, Some(first))
      assert_tokens_equal(lexer.advance(l), rest)
    }
  }
}
