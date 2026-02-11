///|
pub struct AbstractElkGraphValidator {
  epackages : Array[String]
}

///|
pub fn new_abstract_elk_graph_validator() -> AbstractElkGraphValidator {
  { epackages: ["http://www.eclipse.org/elk/ElkGraph"] }
}

///|
pub fn AbstractElkGraphValidator::get_epackages(
  self : AbstractElkGraphValidator,
) -> Array[String] {
  self.epackages
}
