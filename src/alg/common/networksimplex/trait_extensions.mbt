///|
/// Keeps trait methods available through dot syntax.
pub extend NNode with Eq::{not_equal, equal}

///|
pub extend NEdge with Eq::{not_equal, equal}

///|
pub extend NetworkSimplexException with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend NetworkSimplexException with ToJson::{to_json}

///|
pub extend NetworkSimplexException with Show::{to_string, output}
