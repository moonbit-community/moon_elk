///|
/// Keeps trait methods available through dot syntax.
pub extend GraphTextSelectionItem with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend GraphTextExecutableExtensionFactoryException with @moonbitlang/core/debug.Debug::{
  to_repr,
}

///|
pub extend GraphTextExecutableExtensionFactoryException with ToJson::{to_json}

///|
pub extend ElkGraphTextUiActivatorException with @moonbitlang/core/debug.Debug::{
  to_repr,
}

///|
pub extend ElkGraphTextUiActivatorException with ToJson::{to_json}

///|
pub extend GraphTextActivatorException with @moonbitlang/core/debug.Debug::{
  to_repr,
}

///|
pub extend GraphTextActivatorException with ToJson::{to_json}
