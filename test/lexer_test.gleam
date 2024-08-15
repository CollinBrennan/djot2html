import file
import gleam/io
import gleam/option.{Some}
import gleeunit/should
import lexer
import token

pub fn advance_test() {
  let tests = [
    token.LeftCurly,
    token.RightCurly,
    token.Underscore,
    token.Star,
    token.Tick,
    token.Tilde,
    token.Caret,
    token.Equals,
    token.Plus,
    token.Dash,
    token.NewLine,
    token.Text("some other text"),
    token.NewLine,
    token.Text("😂 🥺 ♥️"),
    token.NewLine,
    token.Text("la"),
    token.Plus,
    token.Text("la"),
    token.Dash,
    token.Text("la"),
    token.NewLine,
  ]

  case file.read("./test/test.md") {
    Ok(text) -> assert_tokens_equal(lexer.new(text), tests)
    Error(error) -> io.println_error(error)
  }
}

fn assert_tokens_equal(l: lexer.Lexer, tests: List(token.Token)) {
  let advanced = lexer.advance(l)
  case tests {
    [] -> Nil
    [first] -> {
      should.equal(advanced.current, Some(first))
    }
    [first, ..rest] -> {
      should.equal(advanced.current, Some(first))
      assert_tokens_equal(advanced, rest)
    }
  }
}
