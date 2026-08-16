///|
/// Keeps trait methods available through dot syntax.
pub extend LayerTotalPortDistributorException with @moonbitlang/core/debug.Debug::{
  to_repr,
}

///|
pub extend LayerTotalPortDistributorException with ToJson::{to_json}

///|
pub extend NodeRelativePortDistributorException with @moonbitlang/core/debug.Debug::{
  to_repr,
}

///|
pub extend NodeRelativePortDistributorException with ToJson::{to_json}

///|
pub extend SweepCopyException with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend SweepCopyException with ToJson::{to_json}
