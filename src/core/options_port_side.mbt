///|
pub(all) enum PortSide {
  SideUndefined
  North
  East
  South
  West
}

///|
pub fn port_side_values() -> Array[PortSide] {
  [SideUndefined, North, East, South, West]
}

///|
pub fn port_side_to_string(side : PortSide) -> String {
  match side {
    SideUndefined => "UNDEFINED"
    North => "NORTH"
    East => "EAST"
    South => "SOUTH"
    West => "WEST"
  }
}

///|
pub let sides_none : Array[PortSide] = []

///|
pub let sides_north : Array[PortSide] = [North]

///|
pub let sides_east : Array[PortSide] = [East]

///|
pub let sides_south : Array[PortSide] = [South]

///|
pub let sides_west : Array[PortSide] = [West]

///|
pub let sides_north_south : Array[PortSide] = [North, South]

///|
pub let sides_east_west : Array[PortSide] = [East, West]

///|
pub let sides_north_west : Array[PortSide] = [North, West]

///|
pub let sides_north_east : Array[PortSide] = [North, East]

///|
pub let sides_south_west : Array[PortSide] = [South, West]

///|
pub let sides_east_south : Array[PortSide] = [East, South]

///|
pub let sides_north_east_west : Array[PortSide] = [North, East, West]

///|
pub let sides_east_south_west : Array[PortSide] = [East, South, West]

///|
pub let sides_north_south_west : Array[PortSide] = [North, South, West]

///|
pub let sides_north_east_south : Array[PortSide] = [North, East, South]

///|
pub let sides_north_east_south_west : Array[PortSide] = [
  North,
  East,
  South,
  West,
]

///|
pub fn PortSide::right(self : PortSide) -> PortSide {
  match self {
    North => East
    East => South
    South => West
    West => North
    SideUndefined => SideUndefined
  }
}

///|
pub fn PortSide::left(self : PortSide) -> PortSide {
  match self {
    North => West
    East => North
    South => East
    West => South
    SideUndefined => SideUndefined
  }
}

///|
pub fn PortSide::opposed(self : PortSide) -> PortSide {
  match self {
    North => South
    East => West
    South => North
    West => East
    SideUndefined => SideUndefined
  }
}

///|
fn port_side_equals(left : PortSide, right : PortSide) -> Bool {
  match (left, right) {
    (SideUndefined, SideUndefined) => true
    (North, North) => true
    (East, East) => true
    (South, South) => true
    (West, West) => true
    _ => false
  }
}

///|
pub fn PortSide::are_adjacent(self : PortSide, other : PortSide) -> Bool {
  if port_side_equals(self, SideUndefined) {
    return false
  }
  port_side_equals(self.left(), other) || port_side_equals(self.right(), other)
}

///|
pub fn port_side_from_direction(direction : Direction) -> PortSide {
  match direction {
    Upward => North
    Rightward => East
    Downward => South
    Leftward => West
    Undefined => SideUndefined
  }
}

///|
pub fn port_side_is_vertical(side : PortSide) -> Bool {
  port_side_equals(side, North) || port_side_equals(side, South)
}

///|
pub fn port_side_is_horizontal(side : PortSide) -> Bool {
  port_side_equals(side, West) || port_side_equals(side, East)
}
