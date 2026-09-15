///|
/// Keeps trait methods available through dot syntax.
pub extend JsonImportException with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend JsonImportException with ToJson::{to_json}
