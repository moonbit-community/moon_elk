///|
/// Keeps trait methods available through dot syntax.
pub extend GraphJsonTextNumberValueConverterException with @moonbitlang/core/debug.Debug::{
  to_repr,
}

///|
pub extend GraphJsonTextNumberValueConverterException with ToJson::{to_json}

///|
pub extend GraphJsonTextPropertyKeyValueConverterException with @moonbitlang/core/debug.Debug::{
  to_repr,
}

///|
pub extend GraphJsonTextPropertyKeyValueConverterException with ToJson::{
  to_json,
}

///|
pub extend GraphJsonTextPropertyValue with @moonbitlang/core/debug.Debug::{
  to_repr,
}

///|
pub extend GraphJsonTextPropertyValue with Show::{to_string, output}

///|
pub extend GraphJsonTextListTransient with @moonbitlang/core/debug.Debug::{
  to_repr,
}

///|
pub extend GraphJsonTextListTransient with Show::{to_string, output}

///|
pub extend ElkGraphJsonQualifiedNameConverterException with @moonbitlang/core/debug.Debug::{
  to_repr,
}

///|
pub extend ElkGraphJsonQualifiedNameConverterException with ToJson::{to_json}
