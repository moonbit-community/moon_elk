///|
pub enum PortLabelPlacement {
  Outside
  Inside
  NextToPortIfPossible
  AlwaysSameSide
  AlwaysOtherSameSide
  SpaceEfficient
}

///|
pub fn port_label_placement_values() -> Array[PortLabelPlacement] {
  [
    Outside,
    Inside,
    NextToPortIfPossible,
    AlwaysSameSide,
    AlwaysOtherSameSide,
    SpaceEfficient,
  ]
}

///|
pub fn port_label_placement_to_string(placement : PortLabelPlacement) -> String {
  match placement {
    Outside => "OUTSIDE"
    Inside => "INSIDE"
    NextToPortIfPossible => "NEXT_TO_PORT_IF_POSSIBLE"
    AlwaysSameSide => "ALWAYS_SAME_SIDE"
    AlwaysOtherSameSide => "ALWAYS_OTHER_SAME_SIDE"
    SpaceEfficient => "SPACE_EFFICIENT"
  }
}

///|
fn port_label_placement_equals(
  left : PortLabelPlacement,
  right : PortLabelPlacement,
) -> Bool {
  match (left, right) {
    (Outside, Outside) => true
    (Inside, Inside) => true
    (NextToPortIfPossible, NextToPortIfPossible) => true
    (AlwaysSameSide, AlwaysSameSide) => true
    (AlwaysOtherSameSide, AlwaysOtherSameSide) => true
    (SpaceEfficient, SpaceEfficient) => true
    _ => false
  }
}

///|
fn port_label_placement_has(
  haystack : Array[PortLabelPlacement],
  needle : PortLabelPlacement,
) -> Bool {
  for value in haystack {
    if port_label_placement_equals(value, needle) {
      return true
    }
  }
  false
}

///|
pub fn port_label_placement_fixed() -> Array[PortLabelPlacement] {
  []
}

///|
pub fn port_label_placement_inside() -> Array[PortLabelPlacement] {
  [Inside]
}

///|
pub fn port_label_placement_outside() -> Array[PortLabelPlacement] {
  [Outside]
}

///|
pub fn port_label_placement_is_fixed(
  placement : Array[PortLabelPlacement],
) -> Bool {
  !port_label_placement_has(placement, Inside) &&
  !port_label_placement_has(placement, Outside)
}

///|
fn count_port_label_placement(
  placements : Array[PortLabelPlacement],
  values : Array[PortLabelPlacement],
) -> Int {
  let mut count = 0
  for placement in values {
    if port_label_placement_has(placements, placement) {
      count = count + 1
    }
  }
  count
}

///|
pub fn port_label_placement_is_valid(
  placement : Array[PortLabelPlacement],
) -> Bool {
  if count_port_label_placement(placement, [Inside, Outside]) > 1 {
    return false
  }
  if count_port_label_placement(placement, [
      AlwaysSameSide,
      AlwaysOtherSameSide,
      SpaceEfficient,
    ]) >
    1 {
    return false
  }
  true
}
