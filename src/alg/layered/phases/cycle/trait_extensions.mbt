///|
/// Keeps trait methods available through dot syntax.
pub extend DepthFirstCycleBreakerException with @moonbitlang/core/debug.Debug::{
  to_repr,
}

///|
pub extend DepthFirstCycleBreakerException with ToJson::{to_json}

///|
pub extend DfsNodeOrderCycleBreakerException with @moonbitlang/core/debug.Debug::{
  to_repr,
}

///|
pub extend DfsNodeOrderCycleBreakerException with ToJson::{to_json}

///|
pub extend GreedyCycleBreakerException with @moonbitlang/core/debug.Debug::{
  to_repr,
}

///|
pub extend GreedyCycleBreakerException with ToJson::{to_json}

///|
pub extend InteractiveCycleBreakerException with @moonbitlang/core/debug.Debug::{
  to_repr,
}

///|
pub extend InteractiveCycleBreakerException with ToJson::{to_json}

///|
pub extend ModelOrderCycleBreakerException with @moonbitlang/core/debug.Debug::{
  to_repr,
}

///|
pub extend ModelOrderCycleBreakerException with ToJson::{to_json}

///|
pub extend SCCModelOrderCycleBreakerException with @moonbitlang/core/debug.Debug::{
  to_repr,
}

///|
pub extend SCCModelOrderCycleBreakerException with ToJson::{to_json}
