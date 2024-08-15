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
  case lexer.input {
    [] -> Lexer([], None)
    [first, ..rest] ->
      case first {
        "{" -> Lexer(rest, Some(token.LeftCurly))
        "}" -> Lexer(rest, Some(token.RightCurly))
        "_" -> Lexer(rest, Some(token.Underscore))
        "*" -> Lexer(rest, Some(token.Star))
        "`" -> Lexer(rest, Some(token.Tick))
        "~" -> Lexer(rest, Some(token.Tilde))
        "^" -> Lexer(rest, Some(token.Caret))
        "=" -> Lexer(rest, Some(token.Equals))
        "+" -> Lexer(rest, Some(token.Plus))
        "-" -> Lexer(rest, Some(token.Dash))
        "\r\n" -> Lexer(rest, Some(token.NewLine))
        _ -> tokenize_text(lexer)
      }
  }
}

fn tokenize_text(l: Lexer) -> Lexer {
  let #(input, text) = do_tokenize_text(l.input, "")
  Lexer(input, Some(token.Text(text)))
}

fn do_tokenize_text(
  input: List(String),
  text: String,
) -> #(List(String), String) {
  case input {
    [] -> #([], text)
    [first, ..rest] ->
      case is_text(first) {
        True -> do_tokenize_text(rest, text <> first)
        False -> #([first, ..rest], text)
      }
  }
}

fn is_text(string: String) -> Bool {
  case string {
    "{" | "}" | "_" | "*" | "`" | "~" | "^" | "=" | "+" | "-" | "\r\n" -> False
    _ -> True
  }
}
// pub fn advance(lexer: Lexer) -> Lexer {
//   let next_grapheme = list.first(lexer.input)
//   let token = case next_grapheme {
//     Error(_) -> None
//     Ok(grapheme) ->
//       Some(case grapheme {
//         "{" -> token.Token(token.LeftCurly, grapheme)
//         "}" -> token.Token(token.RightCurly, grapheme)
//         "_" -> token.Token(token.Underscore, grapheme)
//         "*" -> token.Token(token.Star, grapheme)
//         "`" -> token.Token(token.Tick, grapheme)
//         "~" -> token.Token(token.Tilde, grapheme)
//         "^" -> token.Token(token.Caret, grapheme)
//         "=" -> token.Token(token.Equals, grapheme)
//         "+" -> token.Token(token.Plus, grapheme)
//         "-" -> token.Token(token.Dash, grapheme)
//         "\r\n" -> token.Token(token.NewLine, grapheme)
//         _ -> token.Token(token.Text, grapheme)
//       })
//   }

//   let rest = case list.rest(lexer.input) {
//     Error(_) -> []
//     Ok(rest) -> rest
//   }

//   Lexer(rest, token)
// }
