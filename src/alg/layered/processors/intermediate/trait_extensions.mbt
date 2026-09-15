///|
/// Keeps trait methods available through dot syntax.
pub extend LayerConstraintPostprocessorException with @moonbitlang/core/debug.Debug::{
  to_repr,
}

///|
pub extend LayerConstraintPostprocessorException with ToJson::{to_json}

///|
pub extend LayerConstraintPreprocessorException with @moonbitlang/core/debug.Debug::{
  to_repr,
}

///|
pub extend LayerConstraintPreprocessorException with ToJson::{to_json}

///|
pub extend CuttingUtilsException with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend CuttingUtilsException with ToJson::{to_json}
