///|
/// Keeps trait methods available through dot syntax.
pub extend AggregatedMatchDeciderException with @moonbitlang/core/debug.Debug::{
  to_repr,
}

///|
pub extend AggregatedMatchDeciderException with ToJson::{to_json}

///|
pub extend AlignmentMatcherException with @moonbitlang/core/debug.Debug::{
  to_repr,
}

///|
pub extend AlignmentMatcherException with ToJson::{to_json}

///|
pub extend DistanceMatcherException with @moonbitlang/core/debug.Debug::{
  to_repr,
}

///|
pub extend DistanceMatcherException with ToJson::{to_json}

///|
pub extend NodeReferenceMatcherException with @moonbitlang/core/debug.Debug::{
  to_repr,
}

///|
pub extend NodeReferenceMatcherException with ToJson::{to_json}

///|
pub extend SizeFilterException with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend SizeFilterException with ToJson::{to_json}

///|
pub extend TextPrefixFilterException with @moonbitlang/core/debug.Debug::{
  to_repr,
}

///|
pub extend TextPrefixFilterException with ToJson::{to_json}

///|
pub extend KVector with Eq::{not_equal, equal}

///|
pub extend KVector with Hash::{hash, hash_combine}

///|
pub extend ElkSpacingsException with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend ElkSpacingsException with ToJson::{to_json}
