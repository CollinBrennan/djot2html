import gleam/list
import gleam/option.{None, Some}
import lexer
import token

pub type Document {
  Document(List(Section))
}

pub type Section {
  Header(List(Inline))
  Paragraph(List(Inline))
}

pub type Inline {
  Text(String)
  Emphasis(Inner)
  Strong(Inner)
  Code(Inner)
  Sub(Inner)
  Super(Inner)
  Highlight(Inner)
  Underline(Inner)
  Strike(Inner)
  Regular(Inner)
}

pub type Inner =
  List(Inline)

pub fn parse(l: lexer.Lexer) -> Document {
  let advanced = lexer.advance(l)
  case advanced.current {
    None -> Document([])
    Some(_) -> {
      let #(_, sections) = do_parse(l, [])
      Document(sections)
    }
  }
}

fn do_parse(
  l: lexer.Lexer,
  accum: List(Section),
) -> #(lexer.Lexer, List(Section)) {
  case l.current {
    None -> #(l, list.reverse(accum))
    Some(_) -> {
      let #(new_lexer, section) = parse_section(l)
      do_parse(new_lexer, [section, ..accum])
    }
  }
}

fn parse_section(l: lexer.Lexer) -> #(lexer.Lexer, Section) {
  case l.current {
    None -> panic as "parse_section found no tokens"
    Some(_) -> parse_paragraph(l)
  }
}

fn parse_paragraph(l: lexer.Lexer) -> #(lexer.Lexer, Section) {
  let #(new_lexer, inlines) = do_parse_paragraph(l, [])
  #(new_lexer, Paragraph(inlines))
}

fn do_parse_paragraph(
  l: lexer.Lexer,
  accum: List(Inline),
) -> #(lexer.Lexer, List(Inline)) {
  case l.current {
    None -> #(l, list.reverse(accum))
    Some(_) -> {
      let #(new_lexer, inline) = parse_inline(l, "")
      do_parse_paragraph(new_lexer, [inline, ..accum])
    }
  }
}

fn parse_inline(l: lexer.Lexer, text: String) -> #(lexer.Lexer, Inline) {
  let advanced = lexer.advance(l)
  case l.current {
    None -> #(l, Text(text))
    Some(t) ->
      case t {
        token.NewLine -> #(advanced, Text(text))
        token.Underscore ->
          case inline_terminates(advanced, token.Underscore) {
            True -> parse_inline(advanced, text <> "_")
            False -> {
              let #(inner, new_lexer) = lexer.split(advanced, token.Underscore)
              let #(_, inlines) = do_parse_paragraph(inner, [])
              #(new_lexer, Emphasis(inlines))
            }
          }
        token.Star ->
          case inline_terminates(advanced, token.Star) {
            True -> parse_inline(advanced, text <> "*")
            False -> {
              let #(inner, new_lexer) = lexer.split(advanced, token.Star)
              let #(_, inlines) = do_parse_paragraph(inner, [])
              #(new_lexer, Strong(inlines))
            }
          }
        token.Tilde ->
          case inline_terminates(advanced, token.Tilde) {
            True -> parse_inline(advanced, text <> "~")
            False -> {
              let #(inner, new_lexer) = lexer.split(advanced, token.Tilde)
              let #(_, inlines) = do_parse_paragraph(inner, [])
              #(new_lexer, Sub(inlines))
            }
          }
        token.Text(inner) -> parse_inline(advanced, text <> inner)
        _ -> panic as "Token not handled"
      }
  }
}

fn inline_terminates(l: lexer.Lexer, on terminator: token.Token) -> Bool {
  !at_section_end(l)
  && case l.current {
    None -> False
    Some(t) ->
      case t == terminator {
        True -> True
        False -> inline_terminates(lexer.advance(l), terminator)
      }
  }
}

fn at_section_end(l: lexer.Lexer) -> Bool {
  l.current == Some(token.NewLine)
  && {
    lexer.advance(l).current == Some(token.NewLine)
    || lexer.advance(l).current == None
  }
}
