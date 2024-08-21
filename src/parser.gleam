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
}

pub type Graphemes =
  List(String)

pub fn parse(input: String) -> Document {
  let input = string.replace(input, "\r\n", "\n") |> string.to_graphemes()
  let blocks = do_parse(input, [])
  Document(blocks)
}

fn do_parse(input: Graphemes, accum: List(Block)) -> List(Block) {
  case input {
    [] -> list.reverse(accum)
    [first, ..] -> {
      let #(rest, block) = parse_block(input, first)
      do_parse(rest, [block, ..accum])
    }
  }
}

fn parse_block(input: Graphemes, grapheme: String) -> #(Graphemes, Block) {
  case grapheme {
    _ -> parse_paragraph(input)
  }
}

fn parse_paragraph(input: Graphemes) -> #(Graphemes, Block) {
  let #(rest, paragraph_graphemes) = get_paragraph_graphemes(input)
  let inlines = do_parse_paragraph(paragraph_graphemes, [])
  #(rest, Paragraph(inlines))
}

fn do_parse_paragraph(input: Graphemes, accum: List(Inline)) -> List(Inline) {
  case input {
    [] -> list.reverse(accum)
    _ -> {
      let #(rest, inline) = parse_inline(input, "")
      do_parse_paragraph(rest, [inline, ..accum])
    }
  }
}

fn parse_inline(input: Graphemes, text: String) -> #(Graphemes, Inline) {
  case input {
    [] -> #([], Text(text))
    [first, ..rest] ->
      case first {
        "_" ->
          case parse_style(rest, [], "_") {
            None -> parse_inline(rest, text <> "_")
            Some(#(rest, inner)) -> #(
              rest,
              Emphasis(do_parse_paragraph(inner, [])),
            )
          }
        "*" ->
          case parse_style(rest, [], "*") {
            None -> parse_inline(rest, text <> "*")
            Some(#(rest, inner)) -> #(
              rest,
              Strong(do_parse_paragraph(inner, [])),
            )
          }
        "~" ->
          case parse_style(rest, [], "~") {
            None -> parse_inline(rest, text <> "~")
            Some(#(rest, inner)) -> #(rest, Sub(do_parse_paragraph(inner, [])))
          }
        "^" ->
          case parse_style(rest, [], "^") {
            None -> parse_inline(rest, text <> "^")
            Some(#(rest, inner)) -> #(
              rest,
              Super(do_parse_paragraph(inner, [])),
            )
          }
        _ -> parse_inline(rest, text <> first)
      }
  }
}

fn parse_style(
  input: Graphemes,
  accum: Graphemes,
  terminator: String,
) -> Option(#(Graphemes, Graphemes)) {
  case input {
    [] -> None
    [first, ..rest] ->
      case first {
        _ if first == terminator -> Some(#(rest, list.reverse(accum)))
        _ -> parse_style(rest, [first, ..accum], terminator)
      }
  }
}

fn get_paragraph_graphemes(input: Graphemes) -> #(Graphemes, Graphemes) {
  do_get_paragraph_graphemes(input, [])
}

fn do_get_paragraph_graphemes(
  input: Graphemes,
  accum: Graphemes,
) -> #(Graphemes, Graphemes) {
  case input {
    [] -> #([], list.reverse(accum))
    [first] ->
      case first {
        "\n" -> #([], list.reverse(accum))
        _ -> #([], list.reverse([first, ..accum]))
      }
    [first, next, ..rest] ->
      case first, next {
        "\n", "\n" -> #(rest, list.reverse(accum))
        "\n", _ -> do_get_paragraph_graphemes([next, ..rest], [" ", ..accum])
        _, _ -> do_get_paragraph_graphemes([next, ..rest], [first, ..accum])
      }
  }
}
