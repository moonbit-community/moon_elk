///|
/// Keeps trait methods available through dot syntax.
pub extend GraphJsonTextSelectionItem with @moonbitlang/core/debug.Debug::{
  to_repr,
}

///|
pub extend GraphJsonTextExecutableExtensionFactoryException with @moonbitlang/core/debug.Debug::{
  to_repr,
}

///|
pub extend GraphJsonTextExecutableExtensionFactoryException with ToJson::{
  to_json,
}

///|
pub extend ElkGraphJsonTextUiActivatorException with @moonbitlang/core/debug.Debug::{
  to_repr,
}

///|
pub extend ElkGraphJsonTextUiActivatorException with ToJson::{to_json}

///|
pub extend GraphJsonTextActivatorException with @moonbitlang/core/debug.Debug::{
  to_repr,
}

///|
pub extend GraphJsonTextActivatorException with ToJson::{to_json}
