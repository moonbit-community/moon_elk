///|
/// Keeps trait methods available through dot syntax.
pub extend NumberValueConverterException with @moonbitlang/core/debug.Debug::{
  to_repr,
}

///|
pub extend NumberValueConverterException with ToJson::{to_json}

///|
pub extend PropertyKeyValueConverterException with @moonbitlang/core/debug.Debug::{
  to_repr,
}

///|
pub extend PropertyKeyValueConverterException with ToJson::{to_json}

///|
pub extend GraphTextPropertyValue with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend GraphTextPropertyValue with Show::{to_string, output}

///|
pub extend GraphTextListTransient with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend GraphTextListTransient with Show::{to_string, output}

///|
pub extend ElkGraphQualifiedNameConverterException with @moonbitlang/core/debug.Debug::{
  to_repr,
}

///|
pub extend ElkGraphQualifiedNameConverterException with ToJson::{to_json}
