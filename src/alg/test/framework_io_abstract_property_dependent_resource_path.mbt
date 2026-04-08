///|
pub type AbstractPropertyDependentResourcePath = AbstractResourcePath

///|
pub(all) suberror AbstractPropertyDependentResourcePathException {
  IllegalStateException(String)
} derive(Debug, ToJson)

///|
fn[T] abstract_property_dependent_resource_path_raise_illegal_state(
  message : String,
) -> T raise AbstractPropertyDependentResourcePathException {
  raise AbstractPropertyDependentResourcePathException::IllegalStateException(
    message,
  )
}

///|
pub fn base_path_for_property(
  property_name : String,
) -> String raise AbstractPropertyDependentResourcePathException {
  match resource_path_property_value(property_name) {
    Some(path) => path
    None =>
      abstract_property_dependent_resource_path_raise_illegal_state(
        "The system property or environment variable '\{property_name}' needs to be set.",
      )
  }
}
