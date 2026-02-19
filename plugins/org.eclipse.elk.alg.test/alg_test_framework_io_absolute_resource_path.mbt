///|
pub type AbsoluteResourcePath = AbstractResourcePath

///|
pub fn new_absolute_resource_path(file_path : String) -> AbsoluteResourcePath {
  new_abstract_resource_path(None, file_path)
}
