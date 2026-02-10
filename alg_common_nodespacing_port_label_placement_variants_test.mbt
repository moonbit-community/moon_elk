///|
let layered_port_index_option_id = "org.eclipse.elk.layered.portIndex"

///|
fn port_label_variants_port_side_by_name(name : String) -> PortSide {
  for side in port_side_values() {
    if port_side_to_string(side) == name {
      return side
    }
  }
  port_side_values()[0]
}

///|
fn port_label_variants_set_port_side(
  port : ElkPort,
  side_name : String,
) -> Unit {
  port_set_layout_option_string_by_id(port, port_side.get_id(), side_name)
}

///|
fn port_label_variants_get_port_side(port : ElkPort) -> PortSide {
  match port_layout_option_string_value(port, port_side.get_id()) {
    Some(name) => port_label_variants_port_side_by_name(name)
    None => port_side_values()[0]
  }
}

///|
fn port_label_variants_set_port_index(port : ElkPort, index : Int) -> Unit {
  port_set_layout_option_string_by_id(
    port,
    layered_port_index_option_id,
    index.to_string(),
  )
}

///|
fn port_label_variants_get_port_index(port : ElkPort) -> Int {
  match port_layout_option_string_value(port, layered_port_index_option_id) {
    Some(raw) => @strconv.parse_int(raw) catch { _ => 0 }
    None => 0
  }
}

///|
fn port_label_variants_contains_side(
  sides : Array[PortSide],
  side : PortSide,
) -> Bool {
  for current in sides {
    if port_side_to_string(current) == port_side_to_string(side) {
      return true
    }
  }
  false
}

///|
fn port_label_variants_assert_below_or_right(port : ElkPort) -> Unit raise {
  let label = port_labels(port)[0]
  let side = port_label_variants_get_port_side(port)
  let port_position = if port_label_variants_contains_side(
      sides_east_west, side,
    ) {
    label_y(label)
  } else if port_label_variants_contains_side(sides_north_south, side) {
    label_x(label)
  } else {
    fail("Unexpected side in assertBelowOrRight")
    0.0
  }
  assert_true(port_position > 0.0)
}

///|
fn port_label_variants_assert_above_or_left(port : ElkPort) -> Unit raise {
  let label = port_labels(port)[0]
  let side = port_label_variants_get_port_side(port)
  let port_position = if port_label_variants_contains_side(
      sides_east_west, side,
    ) {
    label_y(label)
  } else if port_label_variants_contains_side(sides_north_south, side) {
    label_x(label)
  } else {
    fail("Unexpected side in assertAboveOrLeft")
    0.0
  }
  assert_true(port_position < 0.0)
}

///|
fn port_label_variants_assert_centered(port : ElkPort) -> Unit raise {
  let label = port_labels(port)[0]
  let side = port_label_variants_get_port_side(port)
  if port_label_variants_contains_side(sides_east_west, side) {
    let port_center = 10.0 / 2.0
    let label_center = label_y(label) + label_height(label) / 2.0
    assert_eq(label_center, port_center)
  } else if port_label_variants_contains_side(sides_north_south, side) {
    let port_center = 10.0 / 2.0
    let label_center = label_x(label) + label_width(label) / 2.0
    assert_eq(label_center, port_center)
  } else {
    fail("Unexpected side in assertCentered")
  }
}

///|
fn port_label_variants_add_port(
  node : ElkNode,
  side_name : String,
  index : Int,
  label_x_pos : Double,
  label_y_pos : Double,
) -> ElkPort {
  let port = create_port(Some(node))
  port_label_variants_set_port_side(port, side_name)
  port_label_variants_set_port_index(port, index)

  let label = create_label(Some(make_port_label_parent(port)))
  label_set_location(label, label_x_pos, label_y_pos)
  label_set_dimensions(label, 4.0, 4.0)

  port
}

///|
fn port_label_variants_make_node(
  root : ElkNode,
  identifier : String,
  side_name : String,
  labels_y : Array[Double],
) -> ElkNode {
  let node = create_node(Some(root))
  node_set_identifier(node, identifier)
  node_set_dimensions(node, 50.0, 30.0)
  for i = 0; i < labels_y.length(); i = i + 1 {
    ignore(port_label_variants_add_port(node, side_name, i, 0.0, labels_y[i]))
  }
  node
}

///|
fn port_label_variants_add_edge_to_external(
  port : ElkPort,
  external : ElkNode,
) -> Unit {
  let edge = create_edge(None)
  edge_add_source(edge, make_port_shape(port))
  edge_add_target(edge, make_node_shape(external))
}

///|
fn port_label_variants_fixture(side_name : String) -> ElkNode {
  reset_graph_model_for_test()
  let root = create_graph()
  let external = create_node(Some(root))
  node_set_identifier(external, "external")

  ignore(
    port_label_variants_make_node(root, "outside_two_default", side_name, [
      2.0, -2.0,
    ]),
  )
  ignore(
    port_label_variants_make_node(root, "outside_two_same_side", side_name, [
      2.0, 2.0,
    ]),
  )
  ignore(
    port_label_variants_make_node(root, "outside_two_next_to_port", side_name, [
      3.0, 3.0,
    ]),
  )
  ignore(
    port_label_variants_make_node(root, "outside_three_default", side_name, [
      2.0, 2.0, 2.0,
    ]),
  )
  ignore(
    port_label_variants_make_node(
      root,
      "outside_three_space_efficient",
      side_name,
      [2.0, 2.0, -2.0],
    ),
  )

  ignore(
    port_label_variants_make_node(root, "inside_two_default", side_name, [
      3.0, 3.0,
    ]),
  )
  ignore(
    port_label_variants_make_node(
      root,
      "inside_two_default_hierarchical",
      side_name,
      [2.0, 2.0],
    ),
  )
  ignore(
    port_label_variants_make_node(
      root,
      "inside_two_next_to_port_hierarchical",
      side_name,
      [3.0, 3.0],
    ),
  )

  ignore(
    port_label_variants_make_node(root, "inside_two_with_one_edge", side_name, [
      2.0, 2.0,
    ]),
  )

  let inside_two_with_one_edge_next_to_port = port_label_variants_make_node(
    root,
    "inside_two_with_one_edge_next_to_port",
    side_name,
    [2.0, 3.0],
  )
  let ports_a = node_ports(inside_two_with_one_edge_next_to_port)
  port_label_variants_add_edge_to_external(ports_a[0], external)

  ignore(
    port_label_variants_make_node(
      root,
      "inside_three_with_one_edge",
      side_name,
      [2.0, 2.0, 2.0],
    ),
  )

  let inside_three_with_one_edge_next_to_port = port_label_variants_make_node(
    root,
    "inside_three_with_one_edge_next_to_port",
    side_name,
    [3.0, 2.0, 3.0],
  )
  let ports_b = node_ports(inside_three_with_one_edge_next_to_port)
  port_label_variants_add_edge_to_external(ports_b[1], external)

  root
}

///|
fn port_label_variants_get_ports_of_node(
  parent : ElkNode,
  node_id : String,
) -> Array[ElkPort] {
  let result : Array[ElkPort] = []
  for child in node_children(parent) {
    if node_identifier(child) == node_id {
      for port in node_ports(child) {
        result.push(port)
      }
      break
    }
  }

  for i in 1..<result.length() {
    let key = result[i]
    let mut j = i
    while j > 0 {
      let left = result[j - 1]
      let right = key
      let left_side = port_label_variants_get_port_side(left)
      let left_index = port_label_variants_get_port_index(left)
      let right_index = port_label_variants_get_port_index(right)
      let cmp = if port_label_variants_contains_side(
          sides_south_west, left_side,
        ) {
        left_index - right_index
      } else {
        right_index - left_index
      }
      if cmp <= 0 {
        break
      }
      result[j] = result[j - 1]
      j = j - 1
    }
    result[j] = key
  }

  result
}

///|
test "PortLabelPlacementVariants outside_two_default" {
  let graph = port_label_variants_fixture("WEST")
  let ports = port_label_variants_get_ports_of_node(
    graph, "outside_two_default",
  )
  assert_eq(ports.length(), 2)
  port_label_variants_assert_below_or_right(ports[0])
  port_label_variants_assert_above_or_left(ports[1])
}

///|
test "PortLabelPlacementVariants outside_two_same_side" {
  let graph = port_label_variants_fixture("WEST")
  let ports = port_label_variants_get_ports_of_node(
    graph, "outside_two_same_side",
  )
  assert_eq(ports.length(), 2)
  port_label_variants_assert_below_or_right(ports[0])
  port_label_variants_assert_below_or_right(ports[1])
}

///|
test "PortLabelPlacementVariants outside_two_next_to_port" {
  let graph = port_label_variants_fixture("WEST")
  let ports = port_label_variants_get_ports_of_node(
    graph, "outside_two_next_to_port",
  )
  assert_eq(ports.length(), 2)
  port_label_variants_assert_centered(ports[0])
  port_label_variants_assert_centered(ports[1])
}

///|
test "PortLabelPlacementVariants outside_three_default" {
  let graph = port_label_variants_fixture("WEST")
  let ports = port_label_variants_get_ports_of_node(
    graph, "outside_three_default",
  )
  assert_eq(ports.length(), 3)
  port_label_variants_assert_below_or_right(ports[0])
  port_label_variants_assert_below_or_right(ports[1])
  port_label_variants_assert_below_or_right(ports[2])
}

///|
test "PortLabelPlacementVariants outside_three_space_efficient" {
  let graph = port_label_variants_fixture("WEST")
  let ports = port_label_variants_get_ports_of_node(
    graph, "outside_three_space_efficient",
  )
  assert_eq(ports.length(), 3)
  port_label_variants_assert_below_or_right(ports[0])
  port_label_variants_assert_below_or_right(ports[1])
  port_label_variants_assert_above_or_left(ports[2])
}

///|
test "PortLabelPlacementVariants inside_two_default" {
  let graph = port_label_variants_fixture("WEST")
  let ports = port_label_variants_get_ports_of_node(graph, "inside_two_default")
  assert_eq(ports.length(), 2)
  port_label_variants_assert_centered(ports[0])
  port_label_variants_assert_centered(ports[1])
}

///|
test "PortLabelPlacementVariants inside_two_default_hierarchical" {
  let graph = port_label_variants_fixture("WEST")
  let ports = port_label_variants_get_ports_of_node(
    graph, "inside_two_default_hierarchical",
  )
  assert_eq(ports.length(), 2)
  port_label_variants_assert_below_or_right(ports[0])
  port_label_variants_assert_below_or_right(ports[1])
}

///|
test "PortLabelPlacementVariants inside_two_next_to_port_hierarchical" {
  let graph = port_label_variants_fixture("WEST")
  let ports = port_label_variants_get_ports_of_node(
    graph, "inside_two_next_to_port_hierarchical",
  )
  assert_eq(ports.length(), 2)
  port_label_variants_assert_centered(ports[0])
  port_label_variants_assert_centered(ports[1])
}

///|
test "PortLabelPlacementVariants inside_two_with_one_edge" {
  let graph = port_label_variants_fixture("WEST")
  let ports = port_label_variants_get_ports_of_node(
    graph, "inside_two_with_one_edge",
  )
  assert_eq(ports.length(), 2)
  port_label_variants_assert_below_or_right(ports[0])
  port_label_variants_assert_below_or_right(ports[1])
}

///|
test "PortLabelPlacementVariants inside_two_with_one_edge_next_to_port" {
  let graph = port_label_variants_fixture("WEST")
  let ports = port_label_variants_get_ports_of_node(
    graph, "inside_two_with_one_edge_next_to_port",
  )
  assert_eq(ports.length(), 2)

  let (port_with_edge, other) = if port_outgoing_edges(ports[0]).is_empty() {
    (ports[1], ports[0])
  } else {
    (ports[0], ports[1])
  }

  port_label_variants_assert_below_or_right(port_with_edge)
  port_label_variants_assert_centered(other)
}

///|
test "PortLabelPlacementVariants inside_three_with_one_edge" {
  let graph = port_label_variants_fixture("WEST")
  let ports = port_label_variants_get_ports_of_node(
    graph, "inside_three_with_one_edge",
  )
  assert_eq(ports.length(), 3)
  port_label_variants_assert_below_or_right(ports[0])
  port_label_variants_assert_below_or_right(ports[1])
  port_label_variants_assert_below_or_right(ports[2])
}

///|
test "PortLabelPlacementVariants inside_three_with_one_edge_next_to_port" {
  let graph = port_label_variants_fixture("WEST")
  let ports = port_label_variants_get_ports_of_node(
    graph, "inside_three_with_one_edge_next_to_port",
  )
  assert_eq(ports.length(), 3)
  port_label_variants_assert_centered(ports[0])
  port_label_variants_assert_below_or_right(ports[1])
  port_label_variants_assert_centered(ports[2])
}
