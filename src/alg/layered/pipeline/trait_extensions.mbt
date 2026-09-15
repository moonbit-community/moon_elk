///|
/// Keeps trait methods available through dot syntax.
pub extend ElkLayeredTestExecutionException with @moonbitlang/core/debug.Debug::{
  to_repr,
}

///|
pub extend ElkLayeredTestExecutionException with ToJson::{to_json}
