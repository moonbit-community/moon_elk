///|
fn node_label_placements_to_strings(
  values : Array[NodeLabelPlacement],
) -> Array[String] {
  let result = []
  for value in values {
    result.push(node_label_placement_to_string(value))
  }
  result
}

///|
fn port_label_placements_to_strings(
  values : Array[PortLabelPlacement],
) -> Array[String] {
  let result = []
  for value in values {
    result.push(port_label_placement_to_string(value))
  }
  result
}

///|
fn direction_at(index : Int) -> Direction {
  direction_values()[index]
}

///|
fn port_constraints_at(index : Int) -> PortConstraints {
  port_constraints_values()[index]
}

///|
fn port_side_at(index : Int) -> PortSide {
  port_side_values()[index]
}

///|
fn node_label_placement_at(index : Int) -> NodeLabelPlacement {
  node_label_placement_values()[index]
}

///|
fn port_label_placement_at(index : Int) -> PortLabelPlacement {
  port_label_placement_values()[index]
}

///|
test "Direction helpers" {
  debug_inspect(
    direction_to_string(direction_at(0)),
    content=(
      #|"UNDEFINED"
    ),
  )
  debug_inspect(
    direction_to_string(direction_at(1)),
    content=(
      #|"RIGHT"
    ),
  )
  debug_inspect(
    direction_to_string(direction_at(2)),
    content=(
      #|"LEFT"
    ),
  )
  debug_inspect(
    direction_to_string(direction_at(3)),
    content=(
      #|"DOWN"
    ),
  )
  debug_inspect(
    direction_to_string(direction_at(4)),
    content=(
      #|"UP"
    ),
  )
  debug_inspect(Direction::is_horizontal(direction_at(0)), content="false")
  debug_inspect(Direction::is_horizontal(direction_at(1)), content="true")
  debug_inspect(Direction::is_vertical(direction_at(4)), content="true")
  debug_inspect(Direction::is_vertical(direction_at(2)), content="false")
  debug_inspect(
    direction_to_string(Direction::opposite(direction_at(2))),
    content=(
      #|"RIGHT"
    ),
  )
  debug_inspect(
    direction_to_string(Direction::opposite(direction_at(1))),
    content=(
      #|"LEFT"
    ),
  )
  debug_inspect(
    direction_to_string(Direction::opposite(direction_at(4))),
    content=(
      #|"DOWN"
    ),
  )
  debug_inspect(
    direction_to_string(Direction::opposite(direction_at(3))),
    content=(
      #|"UP"
    ),
  )
  debug_inspect(
    direction_to_string(Direction::opposite(direction_at(0))),
    content=(
      #|"UNDEFINED"
    ),
  )
}

///|
test "PortConstraints helpers" {
  debug_inspect(
    port_constraints_to_string(port_constraints_at(0)),
    content=(
      #|"UNDEFINED"
    ),
  )
  debug_inspect(
    port_constraints_to_string(port_constraints_at(5)),
    content=(
      #|"FIXED_POS"
    ),
  )
  debug_inspect(
    PortConstraints::is_pos_fixed(port_constraints_at(5)),
    content="true",
  )
  debug_inspect(
    PortConstraints::is_pos_fixed(port_constraints_at(4)),
    content="false",
  )
  debug_inspect(
    PortConstraints::is_ratio_fixed(port_constraints_at(4)),
    content="true",
  )
  debug_inspect(
    PortConstraints::is_ratio_fixed(port_constraints_at(5)),
    content="false",
  )
  debug_inspect(
    PortConstraints::is_order_fixed(port_constraints_at(3)),
    content="true",
  )
  debug_inspect(
    PortConstraints::is_order_fixed(port_constraints_at(4)),
    content="true",
  )
  debug_inspect(
    PortConstraints::is_order_fixed(port_constraints_at(5)),
    content="true",
  )
  debug_inspect(
    PortConstraints::is_order_fixed(port_constraints_at(2)),
    content="false",
  )
  debug_inspect(
    PortConstraints::is_side_fixed(port_constraints_at(0)),
    content="false",
  )
  debug_inspect(
    PortConstraints::is_side_fixed(port_constraints_at(1)),
    content="false",
  )
  debug_inspect(
    PortConstraints::is_side_fixed(port_constraints_at(2)),
    content="true",
  )
}

///|
test "PortSide helpers" {
  debug_inspect(
    port_side_to_string(port_side_at(0)),
    content=(
      #|"UNDEFINED"
    ),
  )
  debug_inspect(
    port_side_to_string(port_side_at(1)),
    content=(
      #|"NORTH"
    ),
  )
  debug_inspect(
    port_side_to_string(port_side_at(2)),
    content=(
      #|"EAST"
    ),
  )
  debug_inspect(
    port_side_to_string(port_side_at(3)),
    content=(
      #|"SOUTH"
    ),
  )
  debug_inspect(
    port_side_to_string(port_side_at(4)),
    content=(
      #|"WEST"
    ),
  )
  debug_inspect(
    port_side_to_string(PortSide::right(port_side_at(1))),
    content=(
      #|"EAST"
    ),
  )
  debug_inspect(
    port_side_to_string(PortSide::left(port_side_at(1))),
    content=(
      #|"WEST"
    ),
  )
  debug_inspect(
    port_side_to_string(PortSide::opposed(port_side_at(1))),
    content=(
      #|"SOUTH"
    ),
  )
  debug_inspect(
    PortSide::are_adjacent(port_side_at(1), port_side_at(2)),
    content="true",
  )
  debug_inspect(
    PortSide::are_adjacent(port_side_at(1), port_side_at(3)),
    content="false",
  )
  debug_inspect(
    PortSide::are_adjacent(port_side_at(0), port_side_at(2)),
    content="false",
  )
  debug_inspect(
    port_side_to_string(port_side_from_direction(direction_at(4))),
    content=(
      #|"NORTH"
    ),
  )
  debug_inspect(
    port_side_to_string(port_side_from_direction(direction_at(1))),
    content=(
      #|"EAST"
    ),
  )
  debug_inspect(
    port_side_to_string(port_side_from_direction(direction_at(3))),
    content=(
      #|"SOUTH"
    ),
  )
  debug_inspect(
    port_side_to_string(port_side_from_direction(direction_at(2))),
    content=(
      #|"WEST"
    ),
  )
  debug_inspect(
    port_side_to_string(port_side_from_direction(direction_at(0))),
    content=(
      #|"UNDEFINED"
    ),
  )
  debug_inspect(port_side_is_vertical(port_side_at(1)), content="true")
  debug_inspect(port_side_is_vertical(port_side_at(4)), content="false")
  debug_inspect(port_side_is_horizontal(port_side_at(2)), content="true")
  debug_inspect(port_side_is_horizontal(port_side_at(3)), content="false")
}

///|
test "NodeLabelPlacement helpers" {
  debug_inspect(
    node_label_placements_to_strings(node_label_placement_fixed()),
    content="[]",
  )
  debug_inspect(
    node_label_placements_to_strings(node_label_placement_inside_top_left()),
    content="[\"INSIDE\", \"V_TOP\", \"H_LEFT\"]",
  )
  debug_inspect(
    node_label_placements_to_strings(
      node_label_placement_outside_bottom_right(),
    ),
    content="[\"OUTSIDE\", \"V_BOTTOM\", \"H_RIGHT\"]",
  )
  debug_inspect(
    node_label_placement_is_valid([node_label_placement_at(6)]),
    content="true",
  )
  debug_inspect(
    node_label_placement_is_valid([
      node_label_placement_at(6),
      node_label_placement_at(7),
    ]),
    content="false",
  )
  debug_inspect(
    node_label_placement_is_valid([
      node_label_placement_at(0),
      node_label_placement_at(1),
    ]),
    content="false",
  )
  debug_inspect(
    node_label_placement_is_valid([
      node_label_placement_at(3),
      node_label_placement_at(5),
    ]),
    content="false",
  )
}

///|
test "PortLabelPlacement helpers" {
  debug_inspect(
    port_label_placements_to_strings(port_label_placement_fixed()),
    content="[]",
  )
  debug_inspect(
    port_label_placements_to_strings(port_label_placement_inside()),
    content="[\"INSIDE\"]",
  )
  debug_inspect(
    port_label_placements_to_strings(port_label_placement_outside()),
    content="[\"OUTSIDE\"]",
  )
  debug_inspect(
    port_label_placement_is_fixed([port_label_placement_at(1)]),
    content="false",
  )
  debug_inspect(
    port_label_placement_is_fixed([port_label_placement_at(5)]),
    content="true",
  )
  debug_inspect(
    port_label_placement_is_valid([port_label_placement_at(1)]),
    content="true",
  )
  debug_inspect(
    port_label_placement_is_valid([
      port_label_placement_at(1),
      port_label_placement_at(0),
    ]),
    content="false",
  )
  debug_inspect(
    port_label_placement_is_valid([
      port_label_placement_at(3),
      port_label_placement_at(5),
    ]),
    content="false",
  )
}

///|
test "Size constraint and options helpers" {
  debug_inspect(size_constraint_fixed().length(), content="0")
  debug_inspect(size_constraint_minimum_size().length(), content="1")
  debug_inspect(size_constraint_minimum_size_with_ports().length(), content="2")
  debug_inspect(size_constraint_free().length(), content="4")
  let size_options = size_options_values()
  debug_inspect(
    size_options_to_string(size_options[0]),
    content=(
      #|"DEFAULT_MINIMUM_SIZE"
    ),
  )
  debug_inspect(
    size_options_to_string(size_options[1]),
    content=(
      #|"MINIMUM_SIZE_ACCOUNTS_FOR_PADDING"
    ),
  )
  debug_inspect(
    size_options_to_string(size_options[6]),
    content=(
      #|"SPACE_EFFICIENT_PORT_LABELS"
    ),
  )
  debug_inspect(
    size_options_to_string(size_options_value_of(0)),
    content=(
      #|"DEFAULT_MINIMUM_SIZE"
    ),
  )
  debug_inspect(
    size_options_to_string(size_options_value_of(8)),
    content=(
      #|"ASYMMETRICAL"
    ),
  )
}
