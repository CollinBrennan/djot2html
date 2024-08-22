import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string

pub type Document {
  Document(List(Block))
}

pub type Block {
  Header(List(Inline))
  Paragraph(List(Inline))
}

pub type Inline {
  Text(String)
  Emphasis(List(Inline))
  Strong(List(Inline))
  Code(List(Inline))
  Sub(List(Inline))
  Super(List(Inline))
  Mark(List(Inline))
  Insert(List(Inline))
  Delete(List(Inline))
}

pub type Graphemes =
  String

pub fn parse(input: String) -> Document {
  let input = string.replace(input, "\r\n", "\n")
  let blocks = do_parse(input, [])
  Document(blocks)
}

fn do_parse(input: Graphemes, accum: List(Block)) -> List(Block) {
  case input {
    "" -> list.reverse(accum)
    _ -> {
      let #(rest, block) = parse_block(input)
      do_parse(rest, [block, ..accum])
    }
  }
}

fn parse_block(input: Graphemes) -> #(Graphemes, Block) {
  case input {
    "#" <> _ -> parse_header(input)
    _ -> parse_paragraph(input)
  }
}

fn parse_header(input: Graphemes) {
  todo
}

fn parse_paragraph(input: Graphemes) -> #(Graphemes, Block) {
  let #(rest, paragraph_graphemes) = get_paragraph_graphemes(input, "")
  let inner = parse_inner(paragraph_graphemes, [])
  #(rest, Paragraph(inner))
}

fn parse_inner(input: Graphemes, accum: List(Inline)) -> List(Inline) {
  case input {
    "" -> list.reverse(accum)
    _ -> {
      let #(rest, inline, text) = parse_inline(input, "")
      case text {
        "" -> parse_inner(rest, [inline, ..accum])
        _ -> parse_inner(rest, [inline, Text(text), ..accum])
      }
    }
  }
}

fn parse_inline(input: Graphemes, text: String) -> #(Graphemes, Inline, String) {
  case input {
    "{_" <> rest ->
      case parse_brace_style(rest, "", "_}") {
        None -> parse_inline(rest, text <> "{_")
        Some(#(rest, inner)) -> #(rest, Emphasis(parse_inner(inner, [])), text)
      }
    "{*" <> rest ->
      case parse_brace_style(rest, "", "*}") {
        None -> parse_inline(rest, text <> "{*")
        Some(#(rest, inner)) -> #(rest, Strong(parse_inner(inner, [])), text)
      }
    "{~" <> rest ->
      case parse_brace_style(rest, "", "~}") {
        None -> parse_inline(rest, text <> "{~")
        Some(#(rest, inner)) -> #(rest, Sub(parse_inner(inner, [])), text)
      }
    "{^" <> rest ->
      case parse_brace_style(rest, "", "^}") {
        None -> parse_inline(rest, text <> "{^")
        Some(#(rest, inner)) -> #(rest, Super(parse_inner(inner, [])), text)
      }
    "{=" <> rest ->
      case parse_brace_style(rest, "", "=}") {
        None -> parse_inline(rest, text <> "{=")
        Some(#(rest, inner)) -> #(rest, Mark(parse_inner(inner, [])), text)
      }
    "{+" <> rest ->
      case parse_brace_style(rest, "", "+}") {
        None -> parse_inline(rest, text <> "{+")
        Some(#(rest, inner)) -> #(rest, Insert(parse_inner(inner, [])), text)
      }
    "{-" <> rest ->
      case parse_brace_style(rest, "", "-}") {
        None -> parse_inline(rest, text <> "{-")
        Some(#(rest, inner)) -> #(rest, Delete(parse_inner(inner, [])), text)
      }
    "_" <> rest ->
      case parse_style(rest, "_") {
        None -> parse_inline(rest, text <> "_")
        Some(#(rest, inner)) -> #(rest, Emphasis(parse_inner(inner, [])), text)
      }
    "*" <> rest ->
      case parse_style(rest, "*") {
        None -> parse_inline(rest, text <> "*")
        Some(#(rest, inner)) -> #(rest, Strong(parse_inner(inner, [])), text)
      }
    "~" <> rest ->
      case parse_style(rest, "~") {
        None -> parse_inline(rest, text <> "~")
        Some(#(rest, inner)) -> #(rest, Sub(parse_inner(inner, [])), text)
      }
    "^" <> rest ->
      case parse_style(rest, "^") {
        None -> parse_inline(rest, text <> "^")
        Some(#(rest, inner)) -> #(rest, Super(parse_inner(inner, [])), text)
      }
    _ ->
      case string.pop_grapheme(input) {
        Error(_) -> #("", Text(text), "")
        Ok(#(first, rest)) -> parse_inline(rest, text <> first)
      }
  }
}

fn parse_style(
  input: Graphemes,
  terminator: String,
) -> Option(#(Graphemes, Graphemes)) {
  let graphemes = string.to_graphemes(input)
  case graphemes {
    [] -> None
    [first, ..] if first == terminator || first == " " -> None
    _ ->
      case do_parse_style(graphemes, terminator, "") {
        None -> None
        Some(#(rest, inner)) -> Some(#(string.join(rest, ""), inner))
      }
  }
}

fn do_parse_style(
  input: List(String),
  terminator: String,
  accum: Graphemes,
) -> Option(#(List(String), Graphemes)) {
  case input {
    [] -> None
    [" ", next, ..] if next == terminator -> None
    [first, ..rest] ->
      case first {
        _ if first == terminator -> Some(#(rest, accum))
        _ -> do_parse_style(rest, terminator, accum <> first)
      }
  }
}

fn parse_brace_style(
  input: Graphemes,
  accum: Graphemes,
  terminator: String,
) -> Option(#(Graphemes, Graphemes)) {
  case string.pop_grapheme(input) {
    Error(_) -> None
    Ok(#(first, rest)) ->
      case string.starts_with(input, terminator) {
        True -> {
          let rest = string.drop_left(input, string.length(terminator))
          case accum {
            "" -> None
            _ -> Some(#(rest, accum))
          }
        }
        False -> {
          parse_brace_style(rest, accum <> first, terminator)
        }
      }
  }
}

fn get_paragraph_graphemes(
  input: Graphemes,
  accum: Graphemes,
) -> #(Graphemes, Graphemes) {
  case input {
    "\n" -> #("", accum)
    "\n\n" <> rest -> #(rest, accum)
    "\n" <> rest -> get_paragraph_graphemes(rest, accum <> " ")
    _ ->
      case string.pop_grapheme(input) {
        Error(_) -> #("", accum)
        Ok(#(first, rest)) -> get_paragraph_graphemes(rest, accum <> first)
      }
  }
}
