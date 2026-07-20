///|
pub(all) enum MrtreeEdgeRoutingMode {
  NONE
  MIDDLE_TO_MIDDLE
  AVOID_OVERLAP
}

///|
pub fn mrtree_edge_routing_mode_from_string(
  value : String,
) -> MrtreeEdgeRoutingMode {
  if value == "NONE" {
    NONE
  } else if value == "MIDDLE_TO_MIDDLE" {
    MIDDLE_TO_MIDDLE
  } else {
    AVOID_OVERLAP
  }
}
