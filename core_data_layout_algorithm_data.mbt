///|
pub type GraphValidationFunction = (ElkNode) -> Array[GraphIssue]

///|
pub struct LayoutAlgorithmData {
  id : String
  name : String
  description : String
  validator : GraphValidationFunction?
  known_options : Map[String, Unit]
}

///|
pub fn new_layout_algorithm_data(
  id : String,
  name? : String = "",
  description? : String = "",
  validator? : GraphValidationFunction? = None,
) -> LayoutAlgorithmData {
  { id, name, description, validator, known_options: {} }
}

///|
pub fn LayoutAlgorithmData::get_id(self : LayoutAlgorithmData) -> String {
  self.id
}

///|
pub fn LayoutAlgorithmData::get_validator(
  self : LayoutAlgorithmData,
) -> GraphValidationFunction? {
  self.validator
}

///|
pub fn LayoutAlgorithmData::get_name(self : LayoutAlgorithmData) -> String {
  self.name
}

///|
pub fn LayoutAlgorithmData::get_description(
  self : LayoutAlgorithmData,
) -> String {
  self.description
}

///|
pub fn LayoutAlgorithmData::add_known_option(
  self : LayoutAlgorithmData,
  option_id : String,
) -> Unit {
  self.known_options[option_id] = ()
}

///|
pub fn LayoutAlgorithmData::knows_option(
  self : LayoutAlgorithmData,
  option_id : String,
) -> Bool {
  self.known_options.contains(option_id)
}

///|
pub fn LayoutAlgorithmData::get_known_option_ids(
  self : LayoutAlgorithmData,
) -> Array[String] {
  let ids = []
  self.known_options.each((id, value) => {
    ignore(value)
    ids.push(id)
  })
  ids
}
