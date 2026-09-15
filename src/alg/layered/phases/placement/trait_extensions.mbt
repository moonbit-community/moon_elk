///|
/// Keeps trait methods available through dot syntax.
pub extend BKAlignedLayoutException with @moonbitlang/core/debug.Debug::{
  to_repr,
}

///|
pub extend BKAlignedLayoutException with ToJson::{to_json}

///|
pub extend BkThresholdStrategyException with @moonbitlang/core/debug.Debug::{
  to_repr,
}

///|
pub extend BkThresholdStrategyException with ToJson::{to_json}

///|
pub extend NetworkSimplexPlacerException with @moonbitlang/core/debug.Debug::{
  to_repr,
}

///|
pub extend NetworkSimplexPlacerException with ToJson::{to_json}
