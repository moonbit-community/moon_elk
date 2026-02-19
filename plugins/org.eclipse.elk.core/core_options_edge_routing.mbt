///|
pub enum EdgeRouting {
  RoutingUndefined
  Polyline
  Orthogonal
  Splines
}

///|
pub fn edge_routing_values() -> Array[EdgeRouting] {
  [RoutingUndefined, Polyline, Orthogonal, Splines]
}

///|
pub fn edge_routing_to_string(routing : EdgeRouting) -> String {
  match routing {
    RoutingUndefined => "UNDEFINED"
    Polyline => "POLYLINE"
    Orthogonal => "ORTHOGONAL"
    Splines => "SPLINES"
  }
}
