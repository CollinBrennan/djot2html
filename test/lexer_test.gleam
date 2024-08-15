import gleam/option.{Some}
import gleam/string
import gleeunit
import gleeunit/should
import lexer
import token

pub fn main() {
  gleeunit.main()
}

pub fn lexer_test() {
  let input = "{}_*`~^=+-"
  let l = lexer.new(input)
  let l1 = lexer.advance(l)
  let l2 = lexer.advance(l1)
  let l3 = lexer.advance(l2)
  let l4 = lexer.advance(l3)
  let l5 = lexer.advance(l4)

  should.equal(
    l1,
    lexer.Lexer(
      string.to_graphemes("}_*`~^=+-"),
      Some(token.Token(token.LeftCurly, "{")),
    ),
  )

  should.equal(
    l2,
    lexer.Lexer(
      string.to_graphemes("_*`~^=+-"),
      Some(token.Token(token.RightCurly, "}")),
    ),
  )

  should.equal(
    l3,
    lexer.Lexer(
      string.to_graphemes("*`~^=+-"),
      Some(token.Token(token.Underscore, "_")),
    ),
  )

  should.equal(
    l4,
    lexer.Lexer(
      string.to_graphemes("`~^=+-"),
      Some(token.Token(token.Star, "*")),
    ),
  )

  should.equal(
    l5,
    lexer.Lexer(
      string.to_graphemes("~^=+-"),
      Some(token.Token(token.Tick, "`")),
    ),
  )
}
