///|
pub enum SplineRoutingMode {
  Conservative
  ConservativeSoft
  Sloppy
}

///|
pub fn spline_routing_mode_values() -> Array[SplineRoutingMode] {
  [Conservative, ConservativeSoft, Sloppy]
}

///|
pub fn spline_routing_mode_to_string(mode : SplineRoutingMode) -> String {
  match mode {
    Conservative => "CONSERVATIVE"
    ConservativeSoft => "CONSERVATIVE_SOFT"
    Sloppy => "SLOPPY"
  }
}
