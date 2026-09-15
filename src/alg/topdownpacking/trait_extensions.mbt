///|
/// Keeps trait methods available through dot syntax.
pub extend TopdownpackingGridException with @moonbitlang/core/debug.Debug::{
  to_repr,
}

///|
pub extend TopdownpackingGridException with ToJson::{to_json}
