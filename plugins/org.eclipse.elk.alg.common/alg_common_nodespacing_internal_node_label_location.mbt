///|
pub enum NodeLabelLocation {
  OutTL
  OutTC
  OutTR
  OutBL
  OutBC
  OutBR
  OutLT
  OutLC
  OutLB
  OutRT
  OutRC
  OutRB
  InTL
  InTC
  InTR
  InCL
  InCC
  InCR
  InBL
  InBC
  InBR
  UndefinedNodeLabelLocation
}

///|
pub fn node_label_location_values() -> Array[NodeLabelLocation] {
  [
    OutTL,
    OutTC,
    OutTR,
    OutBL,
    OutBC,
    OutBR,
    OutLT,
    OutLC,
    OutLB,
    OutRT,
    OutRC,
    OutRB,
    InTL,
    InTC,
    InTR,
    InCL,
    InCC,
    InCR,
    InBL,
    InBC,
    InBR,
    UndefinedNodeLabelLocation,
  ]
}

///|
fn node_label_placement_set_equals(
  left : Array[NodeLabelPlacement],
  right : Array[NodeLabelPlacement],
) -> Bool {
  if left.length() != right.length() {
    return false
  }

  for placement in left {
    let mut found = false
    for candidate in right {
      if node_label_placement_to_string(candidate) ==
        node_label_placement_to_string(placement) {
        found = true
        break
      }
    }
    if !found {
      return false
    }
  }

  true
}

///|
fn node_label_location_assigned_placements(
  location : NodeLabelLocation,
) -> Array[Array[NodeLabelPlacement]] {
  match location {
    OutTL => [[NodeLabelOutside, NodeLabelVTop, NodeLabelHLeft]]
    OutTC =>
      [
        [NodeLabelOutside, NodeLabelVTop, NodeLabelHCenter],
        [NodeLabelOutside, NodeLabelVTop, NodeLabelHCenter, NodeLabelHPriority],
      ]
    OutTR => [[NodeLabelOutside, NodeLabelVTop, NodeLabelHRight]]
    OutBL => [[NodeLabelOutside, NodeLabelVBottom, NodeLabelHLeft]]
    OutBC =>
      [
        [NodeLabelOutside, NodeLabelVBottom, NodeLabelHCenter],
        [
          NodeLabelOutside,
          NodeLabelVBottom,
          NodeLabelHCenter,
          NodeLabelHPriority,
        ],
      ]
    OutBR => [[NodeLabelOutside, NodeLabelVBottom, NodeLabelHRight]]
    OutLT =>
      [[NodeLabelOutside, NodeLabelHLeft, NodeLabelVTop, NodeLabelHPriority]]
    OutLC =>
      [
        [NodeLabelOutside, NodeLabelHLeft, NodeLabelVCenter],
        [NodeLabelOutside, NodeLabelHLeft, NodeLabelVCenter, NodeLabelHPriority],
      ]
    OutLB =>
      [[NodeLabelOutside, NodeLabelHLeft, NodeLabelVBottom, NodeLabelHPriority]]
    OutRT =>
      [[NodeLabelOutside, NodeLabelHRight, NodeLabelVTop, NodeLabelHPriority]]
    OutRC =>
      [
        [NodeLabelOutside, NodeLabelHRight, NodeLabelVCenter],
        [
          NodeLabelOutside,
          NodeLabelHRight,
          NodeLabelVCenter,
          NodeLabelHPriority,
        ],
      ]
    OutRB =>
      [
        [
          NodeLabelOutside,
          NodeLabelHRight,
          NodeLabelVBottom,
          NodeLabelHPriority,
        ],
      ]
    InTL =>
      [
        [NodeLabelInside, NodeLabelVTop, NodeLabelHLeft],
        [NodeLabelInside, NodeLabelVTop, NodeLabelHLeft, NodeLabelHPriority],
      ]
    InTC =>
      [
        [NodeLabelInside, NodeLabelVTop, NodeLabelHCenter],
        [NodeLabelInside, NodeLabelVTop, NodeLabelHCenter, NodeLabelHPriority],
      ]
    InTR =>
      [
        [NodeLabelInside, NodeLabelVTop, NodeLabelHRight],
        [NodeLabelInside, NodeLabelVTop, NodeLabelHRight, NodeLabelHPriority],
      ]
    InCL =>
      [
        [NodeLabelInside, NodeLabelVCenter, NodeLabelHLeft],
        [NodeLabelInside, NodeLabelVCenter, NodeLabelHLeft, NodeLabelHPriority],
      ]
    InCC =>
      [
        [NodeLabelInside, NodeLabelVCenter, NodeLabelHCenter],
        [
          NodeLabelInside,
          NodeLabelVCenter,
          NodeLabelHCenter,
          NodeLabelHPriority,
        ],
      ]
    InCR =>
      [
        [NodeLabelInside, NodeLabelVCenter, NodeLabelHRight],
        [NodeLabelInside, NodeLabelVCenter, NodeLabelHRight, NodeLabelHPriority],
      ]
    InBL =>
      [
        [NodeLabelInside, NodeLabelVBottom, NodeLabelHLeft],
        [NodeLabelInside, NodeLabelVBottom, NodeLabelHLeft, NodeLabelHPriority],
      ]
    InBC =>
      [
        [NodeLabelInside, NodeLabelVBottom, NodeLabelHCenter],
        [
          NodeLabelInside,
          NodeLabelVBottom,
          NodeLabelHCenter,
          NodeLabelHPriority,
        ],
      ]
    InBR =>
      [
        [NodeLabelInside, NodeLabelVBottom, NodeLabelHRight],
        [NodeLabelInside, NodeLabelVBottom, NodeLabelHRight, NodeLabelHPriority],
      ]
    UndefinedNodeLabelLocation => []
  }
}

///|
pub fn node_label_location_from_node_label_placement(
  label_placement : Array[NodeLabelPlacement],
) -> NodeLabelLocation {
  for location in node_label_location_values() {
    for assigned in node_label_location_assigned_placements(location) {
      if node_label_placement_set_equals(assigned, label_placement) {
        return location
      }
    }
  }
  UndefinedNodeLabelLocation
}

///|
pub fn NodeLabelLocation::horizontal_alignment(
  self : NodeLabelLocation,
) -> HorizontalLabelAlignment? {
  match self {
    OutTL => Some(Left)
    OutTC => Some(Center)
    OutTR => Some(Right)
    OutBL => Some(Left)
    OutBC => Some(Center)
    OutBR => Some(Right)
    OutLT => Some(Right)
    OutLC => Some(Right)
    OutLB => Some(Right)
    OutRT => Some(Left)
    OutRC => Some(Left)
    OutRB => Some(Left)
    InTL => Some(Left)
    InTC => Some(Center)
    InTR => Some(Right)
    InCL => Some(Left)
    InCC => Some(Center)
    InCR => Some(Right)
    InBL => Some(Left)
    InBC => Some(Center)
    InBR => Some(Right)
    UndefinedNodeLabelLocation => None
  }
}

///|
pub fn NodeLabelLocation::vertical_alignment(
  self : NodeLabelLocation,
) -> VerticalLabelAlignment? {
  match self {
    OutTL => Some(Bottom)
    OutTC => Some(Bottom)
    OutTR => Some(Bottom)
    OutBL => Some(Top)
    OutBC => Some(Top)
    OutBR => Some(Top)
    OutLT => Some(Top)
    OutLC => Some(Center)
    OutLB => Some(Bottom)
    OutRT => Some(Top)
    OutRC => Some(Center)
    OutRB => Some(Bottom)
    InTL => Some(Top)
    InTC => Some(Top)
    InTR => Some(Top)
    InCL => Some(Center)
    InCC => Some(Center)
    InCR => Some(Center)
    InBL => Some(Bottom)
    InBC => Some(Bottom)
    InBR => Some(Bottom)
    UndefinedNodeLabelLocation => None
  }
}

///|
pub fn NodeLabelLocation::container_row(
  self : NodeLabelLocation,
) -> ContainerArea? {
  match self {
    OutTL => Some(Begin)
    OutTC => Some(Begin)
    OutTR => Some(Begin)
    OutBL => Some(End)
    OutBC => Some(End)
    OutBR => Some(End)
    OutLT => Some(Begin)
    OutLC => Some(Center)
    OutLB => Some(End)
    OutRT => Some(Begin)
    OutRC => Some(Center)
    OutRB => Some(End)
    InTL => Some(Begin)
    InTC => Some(Begin)
    InTR => Some(Begin)
    InCL => Some(Center)
    InCC => Some(Center)
    InCR => Some(Center)
    InBL => Some(End)
    InBC => Some(End)
    InBR => Some(End)
    UndefinedNodeLabelLocation => None
  }
}

///|
pub fn NodeLabelLocation::container_column(
  self : NodeLabelLocation,
) -> ContainerArea? {
  match self {
    OutTL => Some(Begin)
    OutTC => Some(Center)
    OutTR => Some(End)
    OutBL => Some(Begin)
    OutBC => Some(Center)
    OutBR => Some(End)
    OutLT => Some(Begin)
    OutLC => Some(Begin)
    OutLB => Some(Begin)
    OutRT => Some(End)
    OutRC => Some(End)
    OutRB => Some(End)
    InTL => Some(Begin)
    InTC => Some(Center)
    InTR => Some(End)
    InCL => Some(Begin)
    InCC => Some(Center)
    InCR => Some(End)
    InBL => Some(Begin)
    InBC => Some(Center)
    InBR => Some(End)
    UndefinedNodeLabelLocation => None
  }
}

///|
pub fn NodeLabelLocation::is_inside_location(self : NodeLabelLocation) -> Bool {
  match self {
    InTL | InTC | InTR | InCL | InCC | InCR | InBL | InBC | InBR => true
    _ => false
  }
}

///|
pub fn NodeLabelLocation::outside_side(self : NodeLabelLocation) -> PortSide {
  match self {
    OutTL | OutTC | OutTR => North
    OutBL | OutBC | OutBR => South
    OutLT | OutLC | OutLB => West
    OutRT | OutRC | OutRB => East
    _ => SideUndefined
  }
}

///|
pub fn node_label_location_to_string(location : NodeLabelLocation) -> String {
  match location {
    OutTL => "OUT_T_L"
    OutTC => "OUT_T_C"
    OutTR => "OUT_T_R"
    OutBL => "OUT_B_L"
    OutBC => "OUT_B_C"
    OutBR => "OUT_B_R"
    OutLT => "OUT_L_T"
    OutLC => "OUT_L_C"
    OutLB => "OUT_L_B"
    OutRT => "OUT_R_T"
    OutRC => "OUT_R_C"
    OutRB => "OUT_R_B"
    InTL => "IN_T_L"
    InTC => "IN_T_C"
    InTR => "IN_T_R"
    InCL => "IN_C_L"
    InCC => "IN_C_C"
    InCR => "IN_C_R"
    InBL => "IN_B_L"
    InBC => "IN_B_C"
    InBR => "IN_B_R"
    UndefinedNodeLabelLocation => "UNDEFINED"
  }
}
