///|
/// Keeps trait methods available through dot syntax.
pub extend ElkEdge with Eq::{not_equal, equal}

///|
pub extend ElkEdge with Hash::{hash, hash_combine}

///|
pub extend ElkEdge with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend ElkEdge with Show::{to_string, output}

///|
pub extend ElkEdgeSection with Eq::{not_equal, equal}

///|
pub extend ElkEdgeSection with Hash::{hash, hash_combine}

///|
pub extend ElkEdgeSection with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend ElkEdgeSection with Show::{to_string, output}

///|
pub extend ElkLabel with Eq::{not_equal, equal}

///|
pub extend ElkLabel with Hash::{hash, hash_combine}

///|
pub extend ElkLabel with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend ElkLabel with Show::{to_string, output}

///|
pub extend ElkNode with Eq::{not_equal, equal}

///|
pub extend ElkNode with Hash::{hash, hash_combine}

///|
pub extend ElkNode with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend ElkNode with Show::{to_string, output}

///|
pub extend ElkPort with Eq::{not_equal, equal}

///|
pub extend ElkPort with Hash::{hash, hash_combine}

///|
pub extend ElkPort with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend ElkPort with Show::{to_string, output}

///|
pub extend PropertyId with Eq::{not_equal, equal}

///|
pub extend PropertyId with Hash::{hash, hash_combine}

///|
pub extend PropertyId with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend ElkGraphUtilException with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend ElkGraphUtilException with ToJson::{to_json}

///|
pub extend ElkGraphUtilException with Show::{to_string, output}
