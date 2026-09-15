///|
/// Keeps trait methods available through dot syntax.
pub extend CGroup with Eq::{not_equal, equal}

///|
pub extend CGroupException with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend CGroupException with ToJson::{to_json}

///|
pub extend CNode with Eq::{not_equal, equal}

///|
pub extend OneDimensionalCompactorException with @moonbitlang/core/debug.Debug::{
  to_repr,
}

///|
pub extend OneDimensionalCompactorException with ToJson::{to_json}

///|
pub extend ScanlineConstraintCalculatorException with @moonbitlang/core/debug.Debug::{
  to_repr,
}

///|
pub extend ScanlineConstraintCalculatorException with ToJson::{to_json}
