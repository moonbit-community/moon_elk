///|
fn issue701_test_setup_plain_java_layout() -> Unit {
  layout_meta_data_service_reset_for_test()
  plain_java_initialization_reset_for_test()
  plain_java_initialization_initialize_plain_java_layout()
}

///|
fn issue701_test_layout(graph : ElkNode) -> Unit {
  let resolver = new_layout_algorithm_resolver()
  apply_visitors(graph, [resolver.to_visitor()])
  let layout_engine = new_recursive_graph_layout_engine()
  layout_engine.layout(graph, new_null_elk_progress_monitor())
}

///|
fn issue701_test_port_side(name : String) -> PortSide {
  for side in port_side_values() {
    if port_side_to_string(side) == name {
      return side
    }
  }
  abort("unknown port side: " + name)
}

///|
fn issue701_test_port_label_placement_strings(
  placements : Array[PortLabelPlacement],
) -> Array[String] {
  let values : Array[String] = []
  for placement in placements {
    values.push(port_label_placement_to_string(placement))
  }
  values
}

///|
fn issue701_test_absolute_node_position(node : ElkNode) -> KVector {
  let absolute = new_kvector_xy(node_x(node), node_y(node))
  match node_parent(node) {
    Some(parent) =>
      ignore(absolute.add(issue701_test_absolute_node_position(parent)))
    None => ()
  }
  absolute
}

///|
fn issue701_test_absolute_port_position(port : ElkPort) -> KVector {
  match port_parent(port) {
    Some(parent_node) =>
      issue701_test_absolute_node_position(parent_node).add_xy(
        port_x(port),
        port_y(port),
      )
    None => new_kvector_xy(port_x(port), port_y(port))
  }
}

///|
fn issue701_test_absolute_label_parent_position(
  parent : ElkLabelParent,
) -> KVector {
  match parent {
    NodeLabelParent(node) => issue701_test_absolute_node_position(node)
    PortLabelParent(port) => issue701_test_absolute_port_position(port)
    EdgeLabelParent(edge) =>
      match edge_containing_node(edge) {
        Some(node) => issue701_test_absolute_node_position(node)
        None => new_kvector()
      }
    LabelLabelParent(label) => issue701_test_absolute_label_position(label)
  }
}

///|
fn issue701_test_absolute_label_position(label : ElkLabel) -> KVector {
  let absolute = new_kvector_xy(label_x(label), label_y(label))
  match label_parent(label) {
    Some(parent) =>
      ignore(absolute.add(issue701_test_absolute_label_parent_position(parent)))
    None => ()
  }
  absolute
}

///|
fn issue701_test_label_inside_node(label : ElkLabel, node : ElkNode) -> Bool {
  let label_position = issue701_test_absolute_label_position(label)
  let node_position = issue701_test_absolute_node_position(node)
  label_position.x >= node_position.x &&
  label_position.y >= node_position.y &&
  label_position.x + label_width(label) <= node_position.x + node_width(node) &&
  label_position.y + label_height(label) <= node_position.y + node_height(node)
}

///|
fn issue701_test_collect_label_shapes(
  node : ElkNode,
  shapes : Array[GraphTestShape],
) -> Unit {
  for label in node_labels(node) {
    shapes.push(graph_test_shape_label(label))
  }
  for port in node_ports(node) {
    for label in port_labels(port) {
      shapes.push(graph_test_shape_label(label))
    }
  }
  for child in node_children(node) {
    issue701_test_collect_label_shapes(child, shapes)
  }
}

///|
fn issue701_test_has_label_overlaps(node : ElkNode) -> Bool {
  let shapes : Array[GraphTestShape] = []
  issue701_test_collect_label_shapes(node, shapes)
  graph_test_utils_have_overlaps(shapes)
}

///|
fn issue701_test_array_contains(
  values : Array[String],
  expected : String,
) -> Bool {
  for value in values {
    if value == expected {
      return true
    }
  }
  false
}

///|
fn issue701_test_connect(source : ElkPort, target : ElkPort) -> Unit {
  let edge = create_edge(None)
  edge_add_source(edge, make_port_shape(source))
  edge_add_target(edge, make_port_shape(target))
  update_containment(Some(edge))
}

///|
fn issue701_test_create_node_with_port_label(
  parent : ElkNode,
  node_id : String,
  port_id : String,
  side : PortSide,
  placement : Array[PortLabelPlacement],
  label_offset : (Double, Double)?,
) -> (ElkNode, ElkPort, ElkLabel) {
  let node = create_node(Some(parent))
  node_set_identifier(node, node_id)
  node_set_dimensions(node, 30.0, 30.0)
  node_set_string_property(node, port_constraints, "FIXED_SIDE")
  node_set_string_set_property(
    node,
    port_labels_placement,
    issue701_test_port_label_placement_strings(placement),
  )

  let node_label = create_label(Some(make_node_label_parent(node)))
  label_set_text(node_label, node_id)
  label_set_dimensions(node_label, 20.0, 10.0)

  let port = create_port(Some(node))
  port_set_identifier(port, port_id)
  port_set_dimensions(port, 10.0, 10.0)
  port_set_layout_option_string_by_id(
    port,
    "org.eclipse.elk.port.side",
    port_side_to_string(side),
  )

  let label = create_label(Some(make_port_label_parent(port)))
  label_set_text(label, node_id + "_" + port_id)
  label_set_dimensions(label, 30.0, 10.0)
  match label_offset {
    Some((x, y)) => label_set_location(label, x, y)
    None => ()
  }

  (node, port, label)
}

///|
test "Issue701 inside labels" {
  reset_graph_model_for_test()
  issue701_test_setup_plain_java_layout()

  let graph = create_graph()
  node_set_string_property(graph, algorithm, "org.eclipse.elk.layered")
  node_set_string_property(graph, edge_routing, "ORTHOGONAL")

  let container = create_node(Some(graph))
  node_set_identifier(container, "Container_OneBorderNode_LabelInside")

  let inside = port_label_placement_inside()
  let (node1, port1, _) = issue701_test_create_node_with_port_label(
    container,
    "MyNode1",
    "P1",
    issue701_test_port_side("NORTH"),
    inside,
    None,
  )
  let (node2, port2, _) = issue701_test_create_node_with_port_label(
    container,
    "MyNode2",
    "P1",
    issue701_test_port_side("EAST"),
    inside,
    None,
  )
  let (node3, port3, _) = issue701_test_create_node_with_port_label(
    container,
    "MyNode3",
    "P1",
    issue701_test_port_side("SOUTH"),
    inside,
    None,
  )
  let (node4, port4, _) = issue701_test_create_node_with_port_label(
    container,
    "MyNode4",
    "P1",
    issue701_test_port_side("WEST"),
    inside,
    None,
  )

  issue701_test_connect(port1, port2)
  issue701_test_connect(port2, port3)
  issue701_test_connect(port3, port4)

  issue701_test_layout(graph)

  assert_false(issue701_test_has_label_overlaps(container))
  assert_true(
    issue701_test_array_contains(
      node_get_string_set_property(node1, port_labels_placement),
      "INSIDE",
    ),
  )
  assert_true(
    issue701_test_array_contains(
      node_get_string_set_property(node2, port_labels_placement),
      "INSIDE",
    ),
  )
  assert_true(
    issue701_test_array_contains(
      node_get_string_set_property(node3, port_labels_placement),
      "INSIDE",
    ),
  )
  assert_true(
    issue701_test_array_contains(
      node_get_string_set_property(node4, port_labels_placement),
      "INSIDE",
    ),
  )
}

///|
test "Issue701 outside labels" {
  reset_graph_model_for_test()
  issue701_test_setup_plain_java_layout()

  let graph = create_graph()
  node_set_string_property(graph, algorithm, "org.eclipse.elk.layered")
  node_set_string_property(graph, edge_routing, "ORTHOGONAL")

  let container = create_node(Some(graph))
  node_set_identifier(container, "Container_OneBorderNode_LabelOutside")

  let outside = port_label_placement_outside()
  let (node1, port1, label1) = issue701_test_create_node_with_port_label(
    container,
    "MyNode1",
    "P1",
    issue701_test_port_side("NORTH"),
    outside,
    None,
  )
  let (node2, port2, label2) = issue701_test_create_node_with_port_label(
    container,
    "MyNode2",
    "P1",
    issue701_test_port_side("EAST"),
    outside,
    None,
  )
  let (node3, port3, label3) = issue701_test_create_node_with_port_label(
    container,
    "MyNode3",
    "P1",
    issue701_test_port_side("SOUTH"),
    outside,
    None,
  )
  let (node4, port4, label4) = issue701_test_create_node_with_port_label(
    container,
    "MyNode4",
    "P1",
    issue701_test_port_side("WEST"),
    outside,
    None,
  )

  issue701_test_connect(port1, port2)
  issue701_test_connect(port2, port3)
  issue701_test_connect(port3, port4)

  issue701_test_layout(graph)

  assert_false(issue701_test_has_label_overlaps(container))
  assert_false(issue701_test_label_inside_node(label1, node1))
  assert_false(issue701_test_label_inside_node(label2, node2))
  assert_false(issue701_test_label_inside_node(label3, node3))
  assert_false(issue701_test_label_inside_node(label4, node4))
}

///|
test "Issue701 mix inside and outside labels" {
  reset_graph_model_for_test()
  issue701_test_setup_plain_java_layout()

  let graph = create_graph()
  node_set_string_property(graph, algorithm, "org.eclipse.elk.layered")
  node_set_string_property(graph, edge_routing, "ORTHOGONAL")

  let container = create_node(Some(graph))
  node_set_identifier(
    container, "Container_SeveralBorderNodes_LabelInsideAndOutside",
  )

  let (inside_node_north, inside_port_north, _) = issue701_test_create_node_with_port_label(
    container,
    "InsideNorth",
    "P1",
    issue701_test_port_side("NORTH"),
    port_label_placement_inside(),
    None,
  )
  let (outside_node_east, outside_port_east, _) = issue701_test_create_node_with_port_label(
    container,
    "OutsideEast",
    "P1",
    issue701_test_port_side("EAST"),
    port_label_placement_outside(),
    None,
  )
  let (inside_node_south, inside_port_south, _) = issue701_test_create_node_with_port_label(
    container,
    "InsideSouth",
    "P1",
    issue701_test_port_side("SOUTH"),
    port_label_placement_inside(),
    None,
  )
  let (outside_node_west, outside_port_west, _) = issue701_test_create_node_with_port_label(
    container,
    "OutsideWest",
    "P1",
    issue701_test_port_side("WEST"),
    port_label_placement_outside(),
    None,
  )

  issue701_test_connect(inside_port_north, outside_port_east)
  issue701_test_connect(outside_port_east, inside_port_south)
  issue701_test_connect(inside_port_south, outside_port_west)

  issue701_test_layout(graph)

  assert_false(issue701_test_has_label_overlaps(container))
  assert_true(
    issue701_test_array_contains(
      node_get_string_set_property(inside_node_north, port_labels_placement),
      "INSIDE",
    ),
  )
  assert_true(
    issue701_test_array_contains(
      node_get_string_set_property(inside_node_south, port_labels_placement),
      "INSIDE",
    ),
  )
  assert_false(
    issue701_test_array_contains(
      node_get_string_set_property(outside_node_east, port_labels_placement),
      "INSIDE",
    ),
  )
  assert_false(
    issue701_test_array_contains(
      node_get_string_set_property(outside_node_west, port_labels_placement),
      "INSIDE",
    ),
  )
}

///|
test "Issue701 fixed inside labels" {
  reset_graph_model_for_test()
  issue701_test_setup_plain_java_layout()

  let graph = create_graph()
  node_set_string_property(graph, algorithm, "org.eclipse.elk.layered")
  node_set_string_property(graph, edge_routing, "ORTHOGONAL")

  let container = create_node(Some(graph))
  node_set_identifier(
    container, "Container_OneBorderNode_LabelFixedPartiallyInside",
  )

  let (node, port, _) = issue701_test_create_node_with_port_label(
    container,
    "MyNode1",
    "P1",
    issue701_test_port_side("NORTH"),
    port_label_placement_fixed(),
    Some((0.0, 0.0)),
  )

  issue701_test_connect(port, port)
  issue701_test_layout(graph)

  assert_false(issue701_test_has_label_overlaps(container))
  assert_true(
    node_get_string_set_property(node, port_labels_placement).is_empty(),
  )
}

///|
test "Issue701 fixed outside labels" {
  reset_graph_model_for_test()
  issue701_test_setup_plain_java_layout()

  let graph = create_graph()
  node_set_string_property(graph, algorithm, "org.eclipse.elk.layered")
  node_set_string_property(graph, edge_routing, "ORTHOGONAL")

  let container = create_node(Some(graph))
  node_set_identifier(container, "Container_OneBorderNode_LabelFixedOutside")

  let (node, port, label) = issue701_test_create_node_with_port_label(
    container,
    "MyNode1",
    "P1",
    issue701_test_port_side("NORTH"),
    port_label_placement_fixed(),
    Some((0.0, -20.0)),
  )

  issue701_test_connect(port, port)
  issue701_test_layout(graph)

  assert_false(issue701_test_has_label_overlaps(container))
  assert_false(issue701_test_label_inside_node(label, node))
}

///|
test "Issue701 fixed mix inside and outside labels" {
  reset_graph_model_for_test()
  issue701_test_setup_plain_java_layout()

  let graph = create_graph()
  node_set_string_property(graph, algorithm, "org.eclipse.elk.layered")
  node_set_string_property(graph, edge_routing, "ORTHOGONAL")

  let container = create_node(Some(graph))
  node_set_identifier(
    container, "Container_SeveralBorderNodes_LabelFixedPartiallyInside",
  )

  let (inside_node, inside_port, _) = issue701_test_create_node_with_port_label(
    container,
    "FixedInside",
    "P1",
    issue701_test_port_side("EAST"),
    port_label_placement_fixed(),
    Some((0.0, 0.0)),
  )
  let (outside_node, outside_port, outside_label) = issue701_test_create_node_with_port_label(
    container,
    "FixedOutside",
    "P1",
    issue701_test_port_side("WEST"),
    port_label_placement_fixed(),
    Some((0.0, -20.0)),
  )

  issue701_test_connect(inside_port, outside_port)
  issue701_test_layout(graph)

  assert_false(issue701_test_has_label_overlaps(container))
  assert_true(
    node_get_string_set_property(inside_node, port_labels_placement).is_empty(),
  )
  assert_false(issue701_test_label_inside_node(outside_label, outside_node))
}
