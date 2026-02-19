///|
pub struct MetaDataFormatter {
  grammar_access : MetaDataGrammarAccess
}

///|
pub fn new_meta_data_formatter(
  grammar_access? : MetaDataGrammarAccess = new_meta_data_grammar_access(),
) -> MetaDataFormatter {
  { grammar_access, }
}

///|
pub fn MetaDataFormatter::get_grammar_access(
  self : MetaDataFormatter,
) -> MetaDataGrammarAccess {
  self.grammar_access
}

///|
fn core_meta_formatter_normalize_spaces(text : String) -> String {
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
  result.trim().to_string()
}

///|
pub fn MetaDataFormatter::format_text(
  self : MetaDataFormatter,
  text : String,
) -> String {
  ignore(self)
  core_meta_formatter_normalize_spaces(text)
}

///|
pub fn MetaDataFormatter::format_bundle(
  self : MetaDataFormatter,
  bundle : CoreMetaMdBundle,
) -> String {
  let label = match bundle.get_label() {
    Some(value) => value
    None => ""
  }
  self.format_text("bundle { label \"" + label + "\" }")
}
