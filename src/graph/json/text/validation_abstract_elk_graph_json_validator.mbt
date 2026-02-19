///|
pub struct AbstractElkGraphJsonValidator {
  epackages : Array[String]
}

///|
pub fn new_abstract_elk_graph_json_validator() -> AbstractElkGraphJsonValidator {
  { epackages: ["http://www.eclipse.org/elk/ElkGraphJson"] }
}

///|
pub fn AbstractElkGraphJsonValidator::get_epackages(
  self : AbstractElkGraphJsonValidator,
) -> Array[String] {
  self.epackages
}
