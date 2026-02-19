///|
pub enum LayeringStrategy {
  LsNetworkSimplex
  LsLongestPath
  LsLongestPathSource
  LsCoffmanGraham
  LsInteractive
  LsStretchWidth
  LsMinWidth
  LsBfModelOrder
  LsDfModelOrder
}

///|
pub fn layering_strategy_to_string(value : LayeringStrategy) -> String {
  match value {
    LsNetworkSimplex => "NETWORK_SIMPLEX"
    LsLongestPath => "LONGEST_PATH"
    LsLongestPathSource => "LONGEST_PATH_SOURCE"
    LsCoffmanGraham => "COFFMAN_GRAHAM"
    LsInteractive => "INTERACTIVE"
    LsStretchWidth => "STRETCH_WIDTH"
    LsMinWidth => "MIN_WIDTH"
    LsBfModelOrder => "BF_MODEL_ORDER"
    LsDfModelOrder => "DF_MODEL_ORDER"
  }
}

///|
pub fn layering_strategy_values() -> Array[String] {
  [
    layering_strategy_to_string(LsNetworkSimplex),
    layering_strategy_to_string(LsLongestPath),
    layering_strategy_to_string(LsLongestPathSource),
    layering_strategy_to_string(LsCoffmanGraham),
    layering_strategy_to_string(LsInteractive),
    layering_strategy_to_string(LsStretchWidth),
    layering_strategy_to_string(LsMinWidth),
    layering_strategy_to_string(LsBfModelOrder),
    layering_strategy_to_string(LsDfModelOrder),
  ]
}
