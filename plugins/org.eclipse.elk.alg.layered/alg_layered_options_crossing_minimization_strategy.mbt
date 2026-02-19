///|
pub enum CrossingMinimizationStrategy {
  CmsLayerSweep
  CmsMedianLayerSweep
  CmsInteractive
  CmsNone
}

///|
pub fn crossing_minimization_strategy_to_string(
  value : CrossingMinimizationStrategy,
) -> String {
  match value {
    CmsLayerSweep => "LAYER_SWEEP"
    CmsMedianLayerSweep => "MEDIAN_LAYER_SWEEP"
    CmsInteractive => "INTERACTIVE"
    CmsNone => "NONE"
  }
}

///|
pub fn crossing_minimization_strategy_values() -> Array[String] {
  [
    crossing_minimization_strategy_to_string(CmsLayerSweep),
    crossing_minimization_strategy_to_string(CmsMedianLayerSweep),
    crossing_minimization_strategy_to_string(CmsInteractive),
    crossing_minimization_strategy_to_string(CmsNone),
  ]
}
