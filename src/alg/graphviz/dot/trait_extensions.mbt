///|
/// Keeps trait methods available through dot syntax.
pub extend GraphvizDotActivatorException with @moonbitlang/core/debug.Debug::{
  to_repr,
}

///|
pub extend GraphvizDotActivatorException with ToJson::{to_json}

///|
pub extend GraphvizDotExecutableExtensionFactoryException with @moonbitlang/core/debug.Debug::{
  to_repr,
}

///|
pub extend GraphvizDotExecutableExtensionFactoryException with ToJson::{to_json}
