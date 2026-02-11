///|
pub struct MelkDocumentationGenerator {
  marker : Unit
}

///|
pub fn new_melk_documentation_generator() -> MelkDocumentationGenerator {
  { marker: () }
}

///|
fn core_meta_doc_or_empty(value : String?) -> String {
  match value {
    Some(text) => text
    None => ""
  }
}

///|
pub fn MelkDocumentationGenerator::generate_algorithm_doc(
  self : MelkDocumentationGenerator,
  algorithm : CoreMetaMdAlgorithm,
) -> String {
  ignore(self)
  let name = core_meta_doc_or_empty(algorithm.get_name())
  let label = core_meta_doc_or_empty(algorithm.get_label())
  let description = core_meta_doc_or_empty(algorithm.get_description())
  "# " +
  (if label == "" { name } else { label }) +
  "\n\n" +
  "Identifier: `" +
  name +
  "`\n\n" +
  description
}

///|
pub fn MelkDocumentationGenerator::generate_option_doc(
  self : MelkDocumentationGenerator,
  option : CoreMetaMdOption,
) -> String {
  ignore(self)
  let name = core_meta_doc_or_empty(option.get_name())
  let label = core_meta_doc_or_empty(option.get_label())
  let description = core_meta_doc_or_empty(option.get_description())
  "# " +
  (if label == "" { name } else { label }) +
  "\n\n" +
  "Identifier: `" +
  name +
  "`\n\n" +
  description
}
