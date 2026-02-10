///|
pub type GraphValidationFunction = (ElkNode) -> Array[GraphIssue]

///|
pub struct LayoutAlgorithmData {
  id : String
  name : String
  description : String
  validator : GraphValidationFunction?
  bundle_name : String
  instance_pool_clear_fn : () -> Unit
  known_options : Map[String, Unit]
}

///|
pub fn new_layout_algorithm_data(
  id : String,
  name? : String = "",
  description? : String = "",
  validator? : GraphValidationFunction? = None,
  bundle_name? : String = "",
  instance_pool_clear_fn? : () -> Unit = () => (),
) -> LayoutAlgorithmData {
  {
    id,
    name,
    description,
    validator,
    bundle_name,
    instance_pool_clear_fn,
    known_options: {},
  }
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
pub fn LayoutAlgorithmData::get_bundle_name(
  self : LayoutAlgorithmData,
) -> String {
  self.bundle_name
}

///|
pub fn LayoutAlgorithmData::clear_instance_pool(
  self : LayoutAlgorithmData,
) -> Unit {
  (self.instance_pool_clear_fn)()
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
