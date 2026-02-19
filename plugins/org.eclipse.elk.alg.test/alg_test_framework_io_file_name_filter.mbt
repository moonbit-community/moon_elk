///|
pub struct FileNameFilter {
  expressions : Array[String]
}

///|
pub fn new_file_name_filter(expression : String) -> FileNameFilter {
  new_file_name_filter_with_expressions([expression])
}

///|
pub fn new_file_name_filter_with_expressions(
  expressions : Array[String],
) -> FileNameFilter {
  { expressions: expressions.copy() }
}

///|
fn file_name_filter_match_expression(
  expression : String,
  file_name : String,
) -> Bool {
  if expression == file_name || expression == ".*" {
    return true
  }
  let simplified = expression.replace_all(old="\\.", new=".")
  if simplified.has_prefix(".*") && simplified.has_suffix(".*") {
    let needle = simplified.unsafe_substring(
      start=2,
      end=simplified.length() - 2,
    )
    return file_name.contains(needle)
  }
  if simplified.has_prefix(".*") {
    let suffix = simplified.unsafe_substring(start=2, end=simplified.length())
    return file_name.has_suffix(suffix)
  }
  if simplified.has_suffix(".*") {
    let prefix = simplified.unsafe_substring(
      start=0,
      end=simplified.length() - 2,
    )
    return file_name.has_prefix(prefix)
  }
  file_name == simplified
}

///|
pub fn FileNameFilter::accept(
  self : FileNameFilter,
  path_name : String,
) -> Bool {
  if !(core_debug_is_regular_file(path_name) ||
    core_debug_is_directory(path_name)) {
    false
  } else if core_debug_is_directory(path_name) {
    true
  } else {
    let file_name = core_debug_path_file_name(path_name)
    for expression in self.expressions {
      if file_name_filter_match_expression(expression, file_name) {
        return true
      }
    }
    false
  }
}

///|
pub fn FileNameFilter::to_filter(self : FileNameFilter) -> ResourcePathFilter {
  path_name => self.accept(path_name)
}
