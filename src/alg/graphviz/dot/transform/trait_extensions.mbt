///|
/// Keeps trait methods available through dot syntax.
pub extend DotExporterException with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend DotExporterException with ToJson::{to_json}

///|
pub extend NeatoModelException with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend NeatoModelException with ToJson::{to_json}

///|
pub extend OverlapModeException with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend OverlapModeException with ToJson::{to_json}
