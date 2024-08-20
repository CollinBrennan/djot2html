import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string

pub type Document {
  Document(List(Section))
}

pub type Section {
  Header(List(Inline))
  Paragraph(List(Inline))
}

pub type Inline {
  Text(String)
  Emphasis(List(Inline))
  Strong(List(Inline))
}

pub type Graphemes =
  List(String)

pub fn parse(input: String) -> Document {
  let input = string.replace(input, "\r\n", "\n") |> string.to_graphemes()
  case input {
    [] -> Document([])
    _ -> {
      let sections = do_parse(input, [])
      Document(sections)
    }
  }
}

fn do_parse(input: Graphemes, accum: List(Section)) -> List(Section) {
  case input {
    [] -> list.reverse(accum)
    _ -> {
      let #(rest, section) = parse_section(input)
      do_parse(rest, [section, ..accum])
    }
  }
}

fn parse_section(input: Graphemes) -> #(Graphemes, Section) {
  case input {
    [] -> panic as "parse_section input was empty"
    [first, ..] ->
      case first {
        _ -> parse_paragraph(input)
      }
  }
}

fn parse_paragraph(input: Graphemes) -> #(Graphemes, Section) {
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
          case parse_emphasis(rest, []) {
            None -> parse_inline(rest, text <> "_")
            Some(#(rest, inner)) -> #(
              rest,
              Emphasis(do_parse_paragraph(inner, [])),
            )
          }
        _ -> parse_inline(rest, text <> first)
      }
  }
}

fn parse_emphasis(
  input: Graphemes,
  accum: Graphemes,
) -> Option(#(Graphemes, List(String))) {
  case input {
    [] -> None
    [first, ..rest] ->
      case first {
        "_" -> Some(#(rest, list.reverse(accum)))
        _ -> parse_emphasis(rest, [first, ..accum])
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
