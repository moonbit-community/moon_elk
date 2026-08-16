///|
/// Keeps trait methods available through dot syntax.
pub extend NubSplineException with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend NubSplineException with ToJson::{to_json}

///|
pub extend RectangleException with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend RectangleException with ToJson::{to_json}
