///|
/// Keeps trait methods available through dot syntax.
pub extend RectpackingWidthApproximationException with @moonbitlang/core/debug.Debug::{
  to_repr,
}

///|
pub extend RectpackingWidthApproximationException with ToJson::{to_json}
