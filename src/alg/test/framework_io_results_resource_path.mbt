///|
pub let results_resource_path_property : String = "RESULTS_PATH"

///|
pub type ResultsResourcePath = AbstractPropertyDependentResourcePath

///|
pub fn new_results_resource_path(relative_path : String) -> ResultsResourcePath {
  if relative_path.is_empty() {
    abort("The file path cannot be empty.")
  }
  new_abstract_resource_path(
    Some(base_path_for_property(results_resource_path_property)),
    relative_path,
  )
}

///|
pub fn ensure_results_path_exists() -> Unit {
  let path = base_path_for_property(results_resource_path_property)
  if !core_debug_is_directory(path) {
    core_debug_register_directory_for_test(path, [])
  }
}
