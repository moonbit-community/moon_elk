///|
pub let bundle_resource_path_property : String = "ELK_REPO"

///|
pub type BundleResourcePath = AbstractPropertyDependentResourcePath

///|
fn bundle_resource_path_bundle_id_to_path(bundle_id : String) -> String {
  let mut path = base_path_for_property(bundle_resource_path_property)
  if !path.has_suffix("/") {
    path = path + "/"
  }
  if bundle_id.has_suffix("test") {
    path = path + "test/"
  } else {
    path = path + "plugins/"
  }
  path + bundle_id
}

///|
pub fn new_bundle_resource_path(
  bundle_id : String,
  file_path : String,
) -> BundleResourcePath {
  if bundle_id.is_empty() {
    abort("The bundle ID cannot be empty.")
  }
  if file_path.is_empty() {
    abort("The file path cannot be empty.")
  }
  new_abstract_resource_path(
    Some(bundle_resource_path_bundle_id_to_path(bundle_id)),
    file_path,
  )
}
