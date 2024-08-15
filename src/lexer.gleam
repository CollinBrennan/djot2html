import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import token

pub type Lexer {
  Lexer(input: List(String), current: Option(token.Token))
}

pub fn new(input: String) -> Lexer {
  Lexer(input: string.to_graphemes(input), current: None)
}

pub fn advance(lexer: Lexer) -> Lexer {
  let next_grapheme = list.first(lexer.input)
  let token = case next_grapheme {
    Error(_) -> None
    Ok(grapheme) ->
      Some(case grapheme {
        "{" -> token.Token(token.LeftCurly, grapheme)
        "}" -> token.Token(token.RightCurly, grapheme)
        "_" -> token.Token(token.Underscore, grapheme)
        "*" -> token.Token(token.Star, grapheme)
        "`" -> token.Token(token.Tick, grapheme)
        "~" -> token.Token(token.Tilde, grapheme)
        "^" -> token.Token(token.Caret, grapheme)
        "=" -> token.Token(token.Equals, grapheme)
        "+" -> token.Token(token.Plus, grapheme)
        "-" -> token.Token(token.Dash, grapheme)
        "\r\n" -> token.Token(token.EOF, grapheme)
        _ -> token.Token(token.Text, grapheme)
      })
  }

  let rest = case list.rest(lexer.input) {
    Error(_) -> []
    Ok(rest) -> rest
  }

  Lexer(rest, token)
}
