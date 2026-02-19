///|
pub enum NodeLabelPlacement {
  NodeLabelHLeft
  NodeLabelHCenter
  NodeLabelHRight
  NodeLabelVTop
  NodeLabelVCenter
  NodeLabelVBottom
  NodeLabelInside
  NodeLabelOutside
  NodeLabelHPriority
}

///|
pub fn node_label_placement_values() -> Array[NodeLabelPlacement] {
  [
    NodeLabelHLeft,
    NodeLabelHCenter,
    NodeLabelHRight,
    NodeLabelVTop,
    NodeLabelVCenter,
    NodeLabelVBottom,
    NodeLabelInside,
    NodeLabelOutside,
    NodeLabelHPriority,
  ]
}

///|
pub fn node_label_placement_to_string(placement : NodeLabelPlacement) -> String {
  match placement {
    NodeLabelHLeft => "H_LEFT"
    NodeLabelHCenter => "H_CENTER"
    NodeLabelHRight => "H_RIGHT"
    NodeLabelVTop => "V_TOP"
    NodeLabelVCenter => "V_CENTER"
    NodeLabelVBottom => "V_BOTTOM"
    NodeLabelInside => "INSIDE"
    NodeLabelOutside => "OUTSIDE"
    NodeLabelHPriority => "H_PRIORITY"
  }
}

///|
pub fn node_label_placement_value_of(i : Int) -> NodeLabelPlacement {
  node_label_placement_values()[i]
}

///|
pub fn node_label_placement_fixed() -> Array[NodeLabelPlacement] {
  []
}

///|
pub fn node_label_placement_inside_top_left() -> Array[NodeLabelPlacement] {
  [NodeLabelInside, NodeLabelVTop, NodeLabelHLeft]
}

///|
pub fn node_label_placement_inside_top_center() -> Array[NodeLabelPlacement] {
  [NodeLabelInside, NodeLabelVTop, NodeLabelHCenter]
}

///|
pub fn node_label_placement_inside_top_right() -> Array[NodeLabelPlacement] {
  [NodeLabelInside, NodeLabelVTop, NodeLabelHRight]
}

///|
pub fn node_label_placement_inside_center() -> Array[NodeLabelPlacement] {
  [NodeLabelInside, NodeLabelVCenter, NodeLabelHCenter]
}

///|
pub fn node_label_placement_inside_bottom_left() -> Array[NodeLabelPlacement] {
  [NodeLabelInside, NodeLabelVBottom, NodeLabelHLeft]
}

///|
pub fn node_label_placement_inside_bottom_center() -> Array[NodeLabelPlacement] {
  [NodeLabelInside, NodeLabelVBottom, NodeLabelHCenter]
}

///|
pub fn node_label_placement_inside_bottom_right() -> Array[NodeLabelPlacement] {
  [NodeLabelInside, NodeLabelVBottom, NodeLabelHRight]
}

///|
pub fn node_label_placement_outside_top_left() -> Array[NodeLabelPlacement] {
  [NodeLabelOutside, NodeLabelVTop, NodeLabelHLeft]
}

///|
pub fn node_label_placement_outside_top_center() -> Array[NodeLabelPlacement] {
  [NodeLabelOutside, NodeLabelVTop, NodeLabelHCenter]
}

///|
pub fn node_label_placement_outside_top_right() -> Array[NodeLabelPlacement] {
  [NodeLabelOutside, NodeLabelVTop, NodeLabelHRight]
}

///|
pub fn node_label_placement_outside_bottom_left() -> Array[NodeLabelPlacement] {
  [NodeLabelOutside, NodeLabelVBottom, NodeLabelHLeft]
}

///|
pub fn node_label_placement_outside_bottom_center() -> Array[NodeLabelPlacement] {
  [NodeLabelOutside, NodeLabelVBottom, NodeLabelHCenter]
}

///|
pub fn node_label_placement_outside_bottom_right() -> Array[NodeLabelPlacement] {
  [NodeLabelOutside, NodeLabelVBottom, NodeLabelHRight]
}

///|
fn count_node_label_placement(
  placements : Array[NodeLabelPlacement],
  values : Array[NodeLabelPlacement],
) -> Int {
  fn equals(left : NodeLabelPlacement, right : NodeLabelPlacement) -> Bool {
    match (left, right) {
      (NodeLabelHLeft, NodeLabelHLeft) => true
      (NodeLabelHCenter, NodeLabelHCenter) => true
      (NodeLabelHRight, NodeLabelHRight) => true
      (NodeLabelVTop, NodeLabelVTop) => true
      (NodeLabelVCenter, NodeLabelVCenter) => true
      (NodeLabelVBottom, NodeLabelVBottom) => true
      (NodeLabelInside, NodeLabelInside) => true
      (NodeLabelOutside, NodeLabelOutside) => true
      (NodeLabelHPriority, NodeLabelHPriority) => true
      _ => false
    }
  }

  fn has(
    haystack : Array[NodeLabelPlacement],
    needle : NodeLabelPlacement,
  ) -> Bool {
    for value in haystack {
      if equals(value, needle) {
        return true
      }
    }
    false
  }

  let mut count = 0
  for placement in values {
    if has(placements, placement) {
      count = count + 1
    }
  }
  count
}

///|
pub fn node_label_placement_is_valid(
  placements : Array[NodeLabelPlacement],
) -> Bool {
  let inside_outside = count_node_label_placement(placements, [
    NodeLabelInside,
    NodeLabelOutside,
  ])
  if inside_outside > 1 {
    return false
  }
  let horizontal = count_node_label_placement(placements, [
    NodeLabelHLeft,
    NodeLabelHCenter,
    NodeLabelHRight,
  ])
  if horizontal > 1 {
    return false
  }
  let vertical = count_node_label_placement(placements, [
    NodeLabelVTop,
    NodeLabelVCenter,
    NodeLabelVBottom,
  ])
  if vertical > 1 {
    return false
  }
  true
}
