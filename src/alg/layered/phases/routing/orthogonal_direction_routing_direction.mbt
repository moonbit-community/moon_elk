///|
pub enum RoutingDirection {
  WestToEast
  NorthToSouth
  SouthToNorth
}

///|
pub fn routing_direction_values() -> Array[RoutingDirection] {
  [WestToEast, NorthToSouth, SouthToNorth]
}

///|
pub fn routing_direction_to_string(direction : RoutingDirection) -> String {
  match direction {
    WestToEast => "WEST_TO_EAST"
    NorthToSouth => "NORTH_TO_SOUTH"
    SouthToNorth => "SOUTH_TO_NORTH"
  }
}
