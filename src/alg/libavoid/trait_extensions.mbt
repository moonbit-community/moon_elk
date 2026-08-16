///|
/// Keeps trait methods available through dot syntax.
pub extend LibavoidCommunicatorException with @moonbitlang/core/debug.Debug::{
  to_repr,
}

///|
pub extend LibavoidCommunicatorException with ToJson::{to_json}

///|
pub extend LibavoidServerStateException with @moonbitlang/core/debug.Debug::{
  to_repr,
}

///|
pub extend LibavoidServerStateException with ToJson::{to_json}
