///|
/// Keeps trait methods available through dot syntax.
pub extend LayoutSetupObject with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend LayoutMappingStatus with Eq::{not_equal, equal}

///|
pub extend LayoutMappingStatus with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend LayoutMappingStatus with Show::{to_string, output}

///|
pub extend MonitoredOperationStatus with Eq::{not_equal, equal}

///|
pub extend MonitoredOperationStatus with @moonbitlang/core/debug.Debug::{
  to_repr,
}

///|
pub extend MonitoredOperationStatus with Show::{to_string, output}
