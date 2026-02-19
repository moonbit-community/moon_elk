///|
pub let model_resource_path_property : String = "MODELS_REPO"

///|
pub type ModelResourcePath = AbstractPropertyDependentResourcePath

///|
pub fn new_model_resource_path(file_path : String) -> ModelResourcePath {
  if file_path.is_empty() {
    abort("The file path cannot be empty.")
  }
  new_abstract_resource_path(
    Some(base_path_for_property(model_resource_path_property)),
    file_path,
  )
}
