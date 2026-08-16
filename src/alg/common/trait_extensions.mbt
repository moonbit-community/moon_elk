///|
/// Keeps trait methods available through dot syntax.
pub extend ScanlineOverlapCheckException with @moonbitlang/core/debug.Debug::{
  to_repr,
}

///|
pub extend ScanlineOverlapCheckException with ToJson::{to_json}

///|
pub extend TEdge with Eq::{not_equal, equal}

///|
pub extend TEdge with Hash::{hash, hash_combine}

///|
pub extend TTriangle with Eq::{not_equal, equal}

///|
pub extend TTriangle with Hash::{hash, hash_combine}
