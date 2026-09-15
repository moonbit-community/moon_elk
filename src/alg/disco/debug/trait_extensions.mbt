///|
/// Keeps trait methods available through dot syntax.
pub extend DisCoGraphRenderingCanvasException with @core_debug.Debug::{to_repr}

///|
pub extend DisCoGraphRenderingCanvasException with ToJson::{to_json}

///|
pub extend DisCoDebugDisplay with Eq::{not_equal, equal}
