///|
pub let all_files_suffix : String = "/**"

///|
pub let all_files_recursive_suffix : String = "/**/"

///|
pub type ResourcePathFilter = (String) -> Bool

///|
pub suberror AbstractResourcePathException {
  AbstractResourcePathException(String)
} derive(Debug, ToJson)

///|
fn abstract_resource_path_raise_unit(
  message : String,
) -> Unit raise AbstractResourcePathException {
  raise AbstractResourcePathException(message)
}

///|
let resource_path_system_properties_ref : Ref[Map[String, String]] = Ref::new({})

///|
pub fn resource_path_set_property_for_test(
  name : String,
  value : String,
) -> Unit {
  resource_path_system_properties_ref.val[name] = value
}

///|
pub fn resource_path_clear_properties_for_test() -> Unit {
  resource_path_system_properties_ref.val.clear()
}

///|
pub fn resource_path_property_value(name : String) -> String? {
  resource_path_system_properties_ref.val.get(name)
}

///|
fn resource_path_normalize_slashes(path : String) -> String {
  path.replace_all(old="\\", new="/")
}

///|
fn resource_path_trim_trailing_slash(path : String) -> String {
  if path.length() > 1 && path.has_suffix("/") {
    path.unsafe_substring(start=0, end=path.length() - 1)
  } else {
    path
  }
}

///|
fn resource_path_join(base : String, relative : String) -> String {
  if base.is_empty() {
    relative
  } else if relative.is_empty() {
    base
  } else if base.has_suffix("/") {
    base + relative
  } else {
    base + "/" + relative
  }
}

///|
fn resource_path_exists(path : String) -> Bool {
  core_debug_is_directory(path) || core_debug_is_regular_file(path)
}

///|
pub struct AbstractResourcePath {
  mut file : String
  mut is_directory : Bool
  mut is_recursive : Bool
  mut filter : ResourcePathFilter?
}

///|
pub fn new_abstract_resource_path(
  base : String?,
  relative : String,
) -> AbstractResourcePath {
  let path = {
    file: "",
    is_directory: false,
    is_recursive: false,
    filter: None,
  }
  path.initialize(base, relative)
  path
}

///|
pub fn AbstractResourcePath::initialize(
  self : AbstractResourcePath,
  base : String?,
  relative : String,
) -> Unit {
  let normalized_base = match base {
    Some(value) => resource_path_normalize_slashes(value)
    None => ""
  }
  if relative.is_empty() {
    try
      abstract_resource_path_raise_unit("Relative path cannot be null.")
    catch {
      AbstractResourcePathException(message) =>
        @core.layout_runtime_report_unsupported_configuration(
          "org.eclipse.elk.alg.test.framework.io.AbstractResourcePath: " +
          message,
        )
    } noraise {
      _ => ()
    }
    self.is_directory = false
    self.is_recursive = false
    self.file = resource_path_trim_trailing_slash(normalized_base)
    return
  }
  let normalized_relative = resource_path_normalize_slashes(relative)
  let base_prefix = if normalized_base.is_empty() {
    ""
  } else if normalized_base.has_suffix("/") {
    normalized_base
  } else {
    normalized_base + "/"
  }
  self.is_directory = false
  self.is_recursive = false
  if normalized_relative.has_suffix(all_files_suffix) {
    self.is_directory = true
    self.file = resource_path_trim_trailing_slash(
      resource_path_join(
        base_prefix,
        normalized_relative.unsafe_substring(
          start=0,
          end=normalized_relative.length() - all_files_suffix.length(),
        ),
      ),
    )
    return
  }
  if normalized_relative.has_suffix(all_files_recursive_suffix) {
    self.is_directory = true
    self.is_recursive = true
    self.file = resource_path_trim_trailing_slash(
      resource_path_join(
        base_prefix,
        normalized_relative.unsafe_substring(
          start=0,
          end=normalized_relative.length() - all_files_recursive_suffix.length(),
        ),
      ),
    )
    return
  }
  self.file = resource_path_trim_trailing_slash(
    resource_path_join(base_prefix, normalized_relative),
  )
}

///|
pub fn AbstractResourcePath::get_file(self : AbstractResourcePath) -> String {
  self.file
}

///|
pub fn AbstractResourcePath::is_directory(self : AbstractResourcePath) -> Bool {
  self.is_directory
}

///|
pub fn AbstractResourcePath::is_recursive(self : AbstractResourcePath) -> Bool {
  self.is_recursive
}

///|
pub fn AbstractResourcePath::get_filter(
  self : AbstractResourcePath,
) -> ResourcePathFilter? {
  self.filter
}

///|
pub fn AbstractResourcePath::set_filter(
  self : AbstractResourcePath,
  filter : ResourcePathFilter?,
) -> Unit {
  self.filter = filter
}

///|
pub fn AbstractResourcePath::with_filter(
  self : AbstractResourcePath,
  file_filter : ResourcePathFilter?,
) -> AbstractResourcePath {
  self.set_filter(file_filter)
  self
}

///|
fn resource_path_filter_accepts(
  filter : ResourcePathFilter?,
  path : String,
) -> Bool {
  match filter {
    Some(check) => check(path)
    None => true
  }
}

///|
fn abstract_resource_path_fill_file_list(
  root_path : AbstractResourcePath,
  directory : String,
  result : Array[AbsoluteResourcePath],
) -> Unit {
  let children = core_debug_directory_children(directory)
  for child in children {
    if !resource_path_filter_accepts(root_path.get_filter(), child) {
      continue
    }
    if core_debug_is_regular_file(child) {
      result.push(new_absolute_resource_path(child))
    } else if core_debug_is_directory(child) && root_path.is_recursive() {
      abstract_resource_path_fill_file_list(root_path, child, result)
    }
  }
}

///|
pub fn AbstractResourcePath::list_resources(
  self : AbstractResourcePath,
) -> Array[AbsoluteResourcePath] {
  let result : Array[AbsoluteResourcePath] = []
  let file = self.get_file()
  if !resource_path_exists(file) {
    return result
  }
  if self.is_directory() && core_debug_is_directory(file) {
    abstract_resource_path_fill_file_list(self, file, result)
    return result
  }
  if !self.is_directory() && core_debug_is_regular_file(file) {
    result.push(new_absolute_resource_path(file))
  }
  result
}

///|
pub fn AbstractResourcePath::to_string(self : AbstractResourcePath) -> String {
  self.get_file()
}
