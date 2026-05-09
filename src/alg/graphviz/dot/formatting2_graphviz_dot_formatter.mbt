///|
pub struct GraphvizDotFormatter {
  grammar_access : GraphvizDotGrammarAccess
}

///|
pub fn new_graphviz_dot_formatter(
  grammar_access? : GraphvizDotGrammarAccess = new_graphviz_dot_grammar_access(),
) -> GraphvizDotFormatter {
  { grammar_access, }
}

///|
pub fn GraphvizDotFormatter::get_grammar_access(
  self : GraphvizDotFormatter,
) -> GraphvizDotGrammarAccess {
  self.grammar_access
}

///|
fn graphviz_dot_formatter_normalize_spaces(text : String) -> String {
  let mut result = ""
  let mut last_space = false
  for char in text {
    if char == ' ' || char == '\n' || char == '\t' || char == '\r' {
      if !last_space {
        result = result + " "
      }
      last_space = true
    } else {
      result = result + char.to_string()
      last_space = false
    }
  }
  result.trim().to_owned()
}

///|
pub fn GraphvizDotFormatter::format_text(
  self : GraphvizDotFormatter,
  text : String,
) -> String {
  ignore(self)
  graphviz_dot_formatter_normalize_spaces(text)
}

///|
pub fn GraphvizDotFormatter::format_request(
  self : GraphvizDotFormatter,
  request : GraphvizDotFormatterRequest,
) -> String {
  if request.is_format_undefined_hidden_regions_only() {
    request.get_text()
  } else {
    self.format_text(request.get_text())
  }
}

///|
pub fn new_graphviz_dot_formatter2(
  formatter? : GraphvizDotFormatter = new_graphviz_dot_formatter(),
) -> GraphvizDotFormatter2 {
  request => formatter.format_request(request)
}
