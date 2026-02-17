///|
pub enum Alignment {
  Automatic
  Left
  Right
  Top
  Bottom
  Center
}

///|
pub fn alignment_to_string(value : Alignment) -> String {
  match value {
    Automatic => "AUTOMATIC"
    Left => "LEFT"
    Right => "RIGHT"
    Top => "TOP"
    Bottom => "BOTTOM"
    Center => "CENTER"
  }
}

///|
pub enum EdgeType {
  NoneType
  Directed
  Undirected
  Association
  Generalization
  Dependency
}

///|
pub fn edge_type_to_string(edge_type : EdgeType) -> String {
  match edge_type {
    NoneType => "NONE"
    Directed => "DIRECTED"
    Undirected => "UNDIRECTED"
    Association => "ASSOCIATION"
    Generalization => "GENERALIZATION"
    Dependency => "DEPENDENCY"
  }
}

///|
pub enum HierarchyHandling {
  Inherit
  IncludeChildren
  SeparateChildren
}

///|
pub fn hierarchy_handling_to_string(value : HierarchyHandling) -> String {
  match value {
    Inherit => "INHERIT"
    IncludeChildren => "INCLUDE_CHILDREN"
    SeparateChildren => "SEPARATE_CHILDREN"
  }
}

///|
pub enum LabelSide {
  Unknown
  Above
  Below
  Inline
}

///|
pub fn label_side_to_string(side : LabelSide) -> String {
  match side {
    Unknown => "UNKNOWN"
    Above => "ABOVE"
    Below => "BELOW"
    Inline => "INLINE"
  }
}

///|
pub fn LabelSide::opposite(self : LabelSide) -> LabelSide {
  match self {
    Above => Below
    Below => Above
    Inline => Inline
    Unknown => Unknown
  }
}

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

///|
pub enum PortAlignment {
  Distributed
  Justified
  Begin
  Center
  End
}

///|
pub fn port_alignment_to_string(alignment : PortAlignment) -> String {
  match alignment {
    Distributed => "DISTRIBUTED"
    Justified => "JUSTIFIED"
    Begin => "BEGIN"
    Center => "CENTER"
    End => "END"
  }
}

///|
pub enum PortConstraints {
  Undefined
  Free
  FixedSide
  FixedOrder
  FixedRatio
  FixedPos
}

///|
pub fn port_constraints_values() -> Array[PortConstraints] {
  [Undefined, Free, FixedSide, FixedOrder, FixedRatio, FixedPos]
}

///|
pub fn port_constraints_to_string(constraint : PortConstraints) -> String {
  match constraint {
    Undefined => "UNDEFINED"
    Free => "FREE"
    FixedSide => "FIXED_SIDE"
    FixedOrder => "FIXED_ORDER"
    FixedRatio => "FIXED_RATIO"
    FixedPos => "FIXED_POS"
  }
}

///|
fn port_constraints_equals(
  left : PortConstraints,
  right : PortConstraints,
) -> Bool {
  match (left, right) {
    (Undefined, Undefined) => true
    (Free, Free) => true
    (FixedSide, FixedSide) => true
    (FixedOrder, FixedOrder) => true
    (FixedRatio, FixedRatio) => true
    (FixedPos, FixedPos) => true
    _ => false
  }
}

///|
pub fn PortConstraints::is_pos_fixed(self : PortConstraints) -> Bool {
  port_constraints_equals(self, FixedPos)
}

///|
pub fn PortConstraints::is_ratio_fixed(self : PortConstraints) -> Bool {
  port_constraints_equals(self, FixedRatio)
}

///|
pub fn PortConstraints::is_order_fixed(self : PortConstraints) -> Bool {
  port_constraints_equals(self, FixedOrder) ||
  port_constraints_equals(self, FixedRatio) ||
  port_constraints_equals(self, FixedPos)
}

///|
pub fn PortConstraints::is_side_fixed(self : PortConstraints) -> Bool {
  !port_constraints_equals(self, Free) &&
  !port_constraints_equals(self, Undefined)
}

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

///|
pub enum PortSide {
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

///|
pub enum ShapeCoords {
  Inherit
  Parent
  Root
}

///|
pub fn shape_coords_to_string(value : ShapeCoords) -> String {
  match value {
    Inherit => "INHERIT"
    Parent => "PARENT"
    Root => "ROOT"
  }
}

///|
pub enum SizeConstraint {
  Ports
  PortLabels
  NodeLabels
  MinimumSize
}

///|
pub fn size_constraint_to_string(constraint : SizeConstraint) -> String {
  match constraint {
    Ports => "PORTS"
    PortLabels => "PORT_LABELS"
    NodeLabels => "NODE_LABELS"
    MinimumSize => "MINIMUM_SIZE"
  }
}

///|
pub fn size_constraint_fixed() -> Array[SizeConstraint] {
  []
}

///|
pub fn size_constraint_minimum_size() -> Array[SizeConstraint] {
  [MinimumSize]
}

///|
pub fn size_constraint_minimum_size_with_ports() -> Array[SizeConstraint] {
  [Ports, MinimumSize]
}

///|
pub fn size_constraint_free() -> Array[SizeConstraint] {
  [Ports, PortLabels, NodeLabels, MinimumSize]
}

///|
pub enum SizeOptions {
  DefaultMinimumSize
  MinimumSizeAccountsForPadding
  ComputePadding
  OutsideNodeLabelsOverhang
  PortsOverhang
  UniformPortSpacing
  SpaceEfficientPortLabels
  ForceTabularNodeLabels
  Asymmetrical
}

///|
pub fn size_options_values() -> Array[SizeOptions] {
  [
    DefaultMinimumSize,
    MinimumSizeAccountsForPadding,
    ComputePadding,
    OutsideNodeLabelsOverhang,
    PortsOverhang,
    UniformPortSpacing,
    SpaceEfficientPortLabels,
    ForceTabularNodeLabels,
    Asymmetrical,
  ]
}

///|
pub fn size_options_to_string(option : SizeOptions) -> String {
  match option {
    DefaultMinimumSize => "DEFAULT_MINIMUM_SIZE"
    MinimumSizeAccountsForPadding => "MINIMUM_SIZE_ACCOUNTS_FOR_PADDING"
    ComputePadding => "COMPUTE_PADDING"
    OutsideNodeLabelsOverhang => "OUTSIDE_NODE_LABELS_OVERHANG"
    PortsOverhang => "PORTS_OVERHANG"
    UniformPortSpacing => "UNIFORM_PORT_SPACING"
    SpaceEfficientPortLabels => "SPACE_EFFICIENT_PORT_LABELS"
    ForceTabularNodeLabels => "FORCE_TABULAR_NODE_LABELS"
    Asymmetrical => "ASYMMETRICAL"
  }
}

///|
pub fn size_options_value_of(i : Int) -> SizeOptions {
  size_options_values()[i]
}

///|
pub enum TopdownNodeTypes {
  ParallelNode
  HierarchicalNode
  RootNode
}

///|
pub fn topdown_node_type_to_string(node_type : TopdownNodeTypes) -> String {
  match node_type {
    ParallelNode => "PARALLEL_NODE"
    HierarchicalNode => "HIERARCHICAL_NODE"
    RootNode => "ROOT_NODE"
  }
}
