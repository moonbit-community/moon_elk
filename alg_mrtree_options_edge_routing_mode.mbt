///|
pub enum MrtreeEdgeRoutingMode {
  NONE
  MIDDLE_TO_MIDDLE
  AVOID_OVERLAP
}

///|
pub fn mrtree_edge_routing_mode_from_string(
  value : String,
) -> MrtreeEdgeRoutingMode {
  if value == "NONE" {
    MrtreeEdgeRoutingMode::NONE
  } else if value == "MIDDLE_TO_MIDDLE" {
    MrtreeEdgeRoutingMode::MIDDLE_TO_MIDDLE
  } else {
    MrtreeEdgeRoutingMode::AVOID_OVERLAP
  }
}
