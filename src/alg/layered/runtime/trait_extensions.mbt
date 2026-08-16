///|
/// Keeps trait methods available through dot syntax.
pub extend SelfLoopHolderException with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend SelfLoopHolderException with ToJson::{to_json}

///|
pub extend SelfLoopTypeException with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend SelfLoopTypeException with ToJson::{to_json}

///|
pub extend LEdgeException with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend LEdgeException with ToJson::{to_json}

///|
pub extend LGraphAdapterException with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend LGraphAdapterException with ToJson::{to_json}

///|
pub extend LGraphUtilException with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend LGraphUtilException with ToJson::{to_json}

///|
pub extend LayeredSpacingsException with @moonbitlang/core/debug.Debug::{
  to_repr,
}

///|
pub extend LayeredSpacingsException with ToJson::{to_json}
