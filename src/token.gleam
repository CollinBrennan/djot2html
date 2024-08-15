pub type Token {
  Token(token_type: TokenType, literal: String)
}

pub type TokenType {
  LeftCurly
  RightCurly
  Underscore
  Star
  Tick
  Tilde
  Caret
  Equals
  Plus
  Dash
  EOF
  Text
}
