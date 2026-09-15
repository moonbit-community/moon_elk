///|
/// Keeps trait methods available through dot syntax.
pub extend NodeLabelCellCreatorException with @moonbitlang/core/debug.Debug::{
  to_repr,
}

///|
pub extend NodeLabelCellCreatorException with ToJson::{to_json}

///|
pub extend PortContextCreatorException with @moonbitlang/core/debug.Debug::{
  to_repr,
}

///|
pub extend PortContextCreatorException with ToJson::{to_json}

///|
pub extend NodeContextException with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend NodeContextException with ToJson::{to_json}
