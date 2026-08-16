///|
/// Keeps trait methods available through dot syntax.
pub extend GraphvizException with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend GraphvizException with ToJson::{to_json}
