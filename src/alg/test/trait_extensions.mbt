///|
/// Keeps trait methods available through dot syntax.
pub extend AbstractPropertyDependentResourcePathException with @core_debug.Debug::{
  to_repr,
}

///|
pub extend AbstractPropertyDependentResourcePathException with ToJson::{to_json}

///|
pub extend AbstractResourcePathException with @core_debug.Debug::{to_repr}

///|
pub extend AbstractResourcePathException with ToJson::{to_json}

///|
pub extend BundleResourcePathException with @core_debug.Debug::{to_repr}

///|
pub extend BundleResourcePathException with ToJson::{to_json}

///|
pub extend ModelResourcePathException with @core_debug.Debug::{to_repr}

///|
pub extend ModelResourcePathException with ToJson::{to_json}

///|
pub extend ResultsResourcePathException with @core_debug.Debug::{to_repr}

///|
pub extend ResultsResourcePathException with ToJson::{to_json}

///|
pub extend LayoutTestRunnerException with @core_debug.Debug::{to_repr}

///|
pub extend LayoutTestRunnerException with ToJson::{to_json}
