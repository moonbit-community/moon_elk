///|
pub enum NodePlacementStrategy {
  NpsSimple
  NpsInteractive
  NpsLinearSegments
  NpsBrandesKoepf
  NpsNetworkSimplex
}

///|
pub fn node_placement_strategy_to_string(
  value : NodePlacementStrategy,
) -> String {
  match value {
    NpsSimple => "SIMPLE"
    NpsInteractive => "INTERACTIVE"
    NpsLinearSegments => "LINEAR_SEGMENTS"
    NpsBrandesKoepf => "BRANDES_KOEPF"
    NpsNetworkSimplex => "NETWORK_SIMPLEX"
  }
}

///|
pub fn node_placement_strategy_values() -> Array[String] {
  [
    node_placement_strategy_to_string(NpsSimple),
    node_placement_strategy_to_string(NpsInteractive),
    node_placement_strategy_to_string(NpsLinearSegments),
    node_placement_strategy_to_string(NpsBrandesKoepf),
    node_placement_strategy_to_string(NpsNetworkSimplex),
  ]
}
