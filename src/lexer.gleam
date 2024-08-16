import gleam/option.{type Option, None, Some}
import gleam/string
import token

pub type Lexer {
  Lexer(input: String, current: Option(token.Token))
}

pub fn new(input: String) -> Lexer {
  Lexer(input: input, current: None)
}

pub fn advance(lexer: Lexer) -> Lexer {
  case lexer.input {
    "" -> Lexer("", None)
    "{" <> rest -> Lexer(rest, Some(token.LeftCurly))
    "}" <> rest -> Lexer(rest, Some(token.RightCurly))
    "_" <> rest -> Lexer(rest, Some(token.Underscore))
    "*" <> rest -> Lexer(rest, Some(token.Star))
    "`" <> rest -> Lexer(rest, Some(token.Tick))
    "~" <> rest -> Lexer(rest, Some(token.Tilde))
    "^" <> rest -> Lexer(rest, Some(token.Caret))
    "=" <> rest -> Lexer(rest, Some(token.Equals))
    "+" <> rest -> Lexer(rest, Some(token.Plus))
    "-" <> rest -> Lexer(rest, Some(token.Dash))
    "\r\n" <> rest | "\n" <> rest -> Lexer(rest, Some(token.NewLine))
    _ -> tokenize_text(lexer)
  }
}

fn tokenize_text(l: Lexer) -> Lexer {
  let #(input, text) = do_tokenize_text(l.input, "")
  Lexer(input, Some(token.Text(text)))
}

fn do_tokenize_text(input: String, text: String) -> #(String, String) {
  let popped = string.pop_grapheme(input)
  case popped {
    Error(_) -> #("", text)
    Ok(#(first, rest)) ->
      case is_text(first) {
        True -> do_tokenize_text(rest, text <> first)
        False -> #(input, text)
      }
  }
}

fn is_text(string: String) -> Bool {
  case string {
    "{" | "}" | "_" | "*" | "`" | "~" | "^" | "=" | "+" | "-" | "\r\n" | "\n" ->
      False
    _ -> True
  }
}
