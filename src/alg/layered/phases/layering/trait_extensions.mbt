///|
/// Keeps trait methods available through dot syntax.
pub extend BreadthFirstModelOrderLayererException with @moonbitlang/core/debug.Debug::{
  to_repr,
}

///|
pub extend BreadthFirstModelOrderLayererException with ToJson::{to_json}

///|
pub extend CoffmanGrahamLayererException with @moonbitlang/core/debug.Debug::{
  to_repr,
}

///|
pub extend CoffmanGrahamLayererException with ToJson::{to_json}

///|
pub extend DepthFirstModelOrderLayererException with @moonbitlang/core/debug.Debug::{
  to_repr,
}

///|
pub extend DepthFirstModelOrderLayererException with ToJson::{to_json}

///|
pub extend InteractiveLayererException with @moonbitlang/core/debug.Debug::{
  to_repr,
}

///|
pub extend InteractiveLayererException with ToJson::{to_json}

///|
pub extend LongestPathLayererException with @moonbitlang/core/debug.Debug::{
  to_repr,
}

///|
pub extend LongestPathLayererException with ToJson::{to_json}

///|
pub extend LongestPathSourceLayererException with @moonbitlang/core/debug.Debug::{
  to_repr,
}

///|
pub extend LongestPathSourceLayererException with ToJson::{to_json}
