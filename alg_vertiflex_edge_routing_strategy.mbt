///|
pub enum EdgeRoutingStrategy {
  STRAIGHT
  BEND
}

///|
pub fn vertiflex_edge_routing_strategy_from_string(
  value : String,
) -> EdgeRoutingStrategy {
  if value == "BEND" {
    EdgeRoutingStrategy::BEND
  } else {
    EdgeRoutingStrategy::STRAIGHT
  }
}
