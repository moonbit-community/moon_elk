///|
/// Keeps trait methods available through dot syntax.
pub extend PolyominoCoords with Eq::{not_equal, equal}

///|
pub extend PolyominoCoords with @moonbitlang/core/debug.Debug::{to_repr}
