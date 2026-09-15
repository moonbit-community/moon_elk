///|
/// Keeps trait methods available through dot syntax.
pub extend CrossHierarchyEdgeComparatorException with @moonbitlang/core/debug.Debug::{
  to_repr,
}

///|
pub extend CrossHierarchyEdgeComparatorException with ToJson::{to_json}
