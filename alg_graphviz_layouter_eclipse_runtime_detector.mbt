///|
pub struct EclipseRuntimeDetector {
  marker : Unit
}

///|
pub fn new_eclipse_runtime_detector() -> EclipseRuntimeDetector {
  { marker: () }
}

///|
pub fn EclipseRuntimeDetector::is_eclipse_running(
  self : EclipseRuntimeDetector,
) -> Bool {
  ignore(self)
  match graphviz_layouter_plugin_get_default() {
    Some(_) => true
    None => false
  }
}

///|
pub fn graphviz_layouter_is_eclipse_running() -> Bool {
  new_eclipse_runtime_detector().is_eclipse_running()
}
