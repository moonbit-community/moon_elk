///|
/// Keeps trait methods available through dot syntax.
pub extend ForceImportException with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend ForceImportException with ToJson::{to_json}

///|
pub extend FBendpoint with Eq::{not_equal, equal}

///|
pub extend FEdge with Eq::{not_equal, equal}

///|
pub extend FLabel with Eq::{not_equal, equal}

///|
pub extend FNode with Eq::{not_equal, equal}

///|
pub extend StressMajorizationException with @moonbitlang/core/debug.Debug::{
  to_repr,
}

///|
pub extend StressMajorizationException with ToJson::{to_json}
