///|
pub enum SelfLoopType {
  OneSide
  TwoSidesCorner
  TwoSidesOpposing
  ThreeSides
  FourSides
}

///|
fn self_loop_port_side_eq(left : @core.PortSide, right : @core.PortSide) -> Bool {
  match (left, right) {
    (@core.PortSide::SideUndefined, @core.PortSide::SideUndefined) => true
    (North, North) => true
    (East, East) => true
    (South, South) => true
    (West, West) => true
    _ => false
  }
}

///|
fn self_loop_port_sides_contains(
  port_sides : Array[@core.PortSide],
  target : @core.PortSide,
) -> Bool {
  for side in port_sides {
    if self_loop_port_side_eq(side, target) {
      return true
    }
  }
  false
}

///|
fn self_loop_unique_port_sides(port_sides : Array[@core.PortSide]) -> Array[@core.PortSide] {
  let unique = []
  for side in port_sides {
    if !self_loop_port_sides_contains(unique, side) {
      unique.push(side)
    }
  }
  unique
}

///|
pub fn self_loop_type_from_port_sides(
  port_sides : Array[@core.PortSide],
) -> SelfLoopType? {
  for side in port_sides {
    if self_loop_port_side_eq(side, @core.PortSide::SideUndefined) {
      abort("Port sides must not contain UNDEFINED")
    }
  }

  let unique = self_loop_unique_port_sides(port_sides)
  match unique.length() {
    1 => Some(OneSide)
    2 => {
      let east_west = self_loop_port_sides_contains(unique, East) &&
        self_loop_port_sides_contains(unique, West)
      let north_south = self_loop_port_sides_contains(unique, North) &&
        self_loop_port_sides_contains(unique, South)
      if east_west || north_south {
        Some(TwoSidesOpposing)
      } else {
        Some(TwoSidesCorner)
      }
    }
    3 => Some(ThreeSides)
    4 => Some(FourSides)
    _ => None
  }
}

///|
pub fn self_loop_type_to_string(value : SelfLoopType) -> String {
  match value {
    OneSide => "ONE_SIDE"
    TwoSidesCorner => "TWO_SIDES_CORNER"
    TwoSidesOpposing => "TWO_SIDES_OPPOSING"
    ThreeSides => "THREE_SIDES"
    FourSides => "FOUR_SIDES"
  }
}

///|
pub fn self_loop_type_option_to_string(value : SelfLoopType?) -> String {
  match value {
    Some(result) => self_loop_type_to_string(result)
    None => "NONE"
  }
}
