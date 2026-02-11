///|
pub struct FileExtensionFilter {
  extensions : Array[String]
}

///|
pub fn new_file_extension_filter(extension : String) -> FileExtensionFilter {
  new_file_extension_filter_with_extensions([extension])
}

///|
pub fn new_file_extension_filter_with_extensions(
  extensions : Array[String],
) -> FileExtensionFilter {
  let normalized : Array[String] = []
  for extension in extensions {
    if extension.has_prefix(".") {
      normalized.push(extension)
    } else {
      normalized.push("." + extension)
    }
  }
  { extensions: normalized }
}

///|
fn file_extension_filter_any_match(
  extensions : Array[String],
  file_name : String,
) -> Bool {
  for extension in extensions {
    if file_name.has_suffix(extension) {
      return true
    }
  }
  false
}

///|
pub fn FileExtensionFilter::accept(
  self : FileExtensionFilter,
  path_name : String,
) -> Bool {
  if !(core_debug_is_regular_file(path_name) ||
    core_debug_is_directory(path_name)) {
    false
  } else if core_debug_is_directory(path_name) {
    true
  } else {
    let file_name = core_debug_path_file_name(path_name)
    file_extension_filter_any_match(self.extensions, file_name)
  }
}

///|
pub fn FileExtensionFilter::to_filter(
  self : FileExtensionFilter,
) -> ResourcePathFilter {
  path_name => self.accept(path_name)
}
