///|
pub type AbstractPropertyDependentResourcePath = AbstractResourcePath

///|
pub fn base_path_for_property(property_name : String) -> String {
  match resource_path_property_value(property_name) {
    Some(path) => path
    None =>
      abort(
        "The system property or environment variable '\{property_name}' needs to be set.",
      )
  }
}
