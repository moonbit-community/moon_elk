///|
/// Keeps trait methods available through dot syntax.
pub extend RadialCompactionStrategyException with @moonbitlang/core/debug.Debug::{
  to_repr,
}

///|
pub extend RadialCompactionStrategyException with ToJson::{to_json}
