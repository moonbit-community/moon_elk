///|
pub type GraphValidationFunction = (ElkNode) -> Array[GraphIssue]

///|
pub struct LayoutAlgorithmData {
  id : String
  name : String
  description : String
  validator : GraphValidationFunction?
  mut category_id : String
  bundle_name : String
  mut preview_image_path : String
  mut defining_bundle_id : String
  instance_pool_clear_fn : () -> Unit
  supported_features : Map[String, GraphFeature]
  known_options : Map[String, Unit]
}

///|
pub fn new_layout_algorithm_data(
  id : String,
  name? : String = "",
  description? : String = "",
  validator? : GraphValidationFunction? = None,
  category_id? : String = "",
  bundle_name? : String = "",
  preview_image_path? : String = "",
  defining_bundle_id? : String = "",
  instance_pool_clear_fn? : () -> Unit = () => (),
) -> LayoutAlgorithmData {
  {
    id,
    name,
    description,
    validator,
    category_id,
    bundle_name,
    preview_image_path,
    defining_bundle_id,
    instance_pool_clear_fn,
    supported_features: {},
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
pub fn LayoutAlgorithmData::get_preview_image_path(
  self : LayoutAlgorithmData,
) -> String {
  self.preview_image_path
}

///|
pub fn LayoutAlgorithmData::set_preview_image_path(
  self : LayoutAlgorithmData,
  path : String,
) -> Unit {
  self.preview_image_path = path
}

///|
pub fn LayoutAlgorithmData::get_defining_bundle_id(
  self : LayoutAlgorithmData,
) -> String {
  self.defining_bundle_id
}

///|
pub fn LayoutAlgorithmData::set_defining_bundle_id(
  self : LayoutAlgorithmData,
  bundle_id : String,
) -> Unit {
  self.defining_bundle_id = bundle_id
}

///|
pub fn LayoutAlgorithmData::get_category_id(
  self : LayoutAlgorithmData,
) -> String {
  self.category_id
}

///|
pub fn LayoutAlgorithmData::set_category_id(
  self : LayoutAlgorithmData,
  category_id : String,
) -> Unit {
  self.category_id = category_id
}

///|
pub fn LayoutAlgorithmData::clear_instance_pool(
  self : LayoutAlgorithmData,
) -> Unit {
  (self.instance_pool_clear_fn)()
}

///|
pub fn LayoutAlgorithmData::add_supported_feature(
  self : LayoutAlgorithmData,
  feature : GraphFeature,
) -> Unit {
  self.supported_features[feature.to_string()] = feature
}

///|
pub fn LayoutAlgorithmData::supports_feature(
  self : LayoutAlgorithmData,
  feature : GraphFeature,
) -> Bool {
  self.supported_features.contains(feature.to_string())
}

///|
pub fn LayoutAlgorithmData::get_supported_features(
  self : LayoutAlgorithmData,
) -> Array[GraphFeature] {
  let features = []
  self.supported_features.each((id, feature) => {
    ignore(id)
    features.push(feature)
  })
  features
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
