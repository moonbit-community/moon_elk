///|
/// Keeps trait methods available through dot syntax.
pub extend MrtreeEdge with Eq::{not_equal, equal}

///|
pub extend MrtreeGraph with Eq::{not_equal, equal}

///|
pub extend MrtreeLabel with Eq::{not_equal, equal}

///|
pub extend MrtreeLabel with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend MrtreeNode with Eq::{not_equal, equal}

///|
pub extend MrtreeNode with Hash::{hash, hash_combine}
