///|
fn allow_non_flow_ports_test_setup_plain_java_layout() -> Unit {
  layout_meta_data_service_reset_for_test()
  plain_java_initialization_reset_for_test()
  plain_java_initialization_initialize_plain_java_layout()
}

///|
fn allow_non_flow_ports_test_layout(graph : @graph.ElkNode) -> Unit {
  let resolver = new_layout_algorithm_resolver()
  apply_visitors(graph, [resolver.to_visitor()])
  let layout_engine = new_recursive_graph_layout_engine()
  layout_engine.layout(graph, @core.new_null_elk_progress_monitor())
}

///|
fn allow_non_flow_ports_test_create_graph(
  port_constraints : String,
  node1_may_switch : Bool,
  node2_may_switch : Bool,
) -> @graph.ElkNode {
  let graph = create_graph()

  let node1 = @graph.create_node(Some(graph))
  @graph.node_set_dimensions(node1, 30.0, 30.0)
  @graph.node_set_layout_option_string_by_id(
    node1, "org.eclipse.elk.portConstraints", port_constraints,
  )

  let n1_north = create_port(Some(node1))
  port_set_dimensions(n1_north, 2.0, 2.0)
  port_set_location(n1_north, 15.0, -1.0)
  port_set_layout_option_string_by_id(
    n1_north, "org.eclipse.elk.port.side", "NORTH",
  )
  port_set_layout_option_string_by_id(
    n1_north,
    "org.eclipse.elk.layered.allowNonFlowPortsToSwitchSides",
    if node1_may_switch {
      "true"
    } else {
      "false"
    },
  )

  let n1_south = create_port(Some(node1))
  port_set_dimensions(n1_south, 2.0, 2.0)
  port_set_location(n1_south, 15.0, 30.0)
  port_set_layout_option_string_by_id(
    n1_south, "org.eclipse.elk.port.side", "SOUTH",
  )
  port_set_layout_option_string_by_id(
    n1_south,
    "org.eclipse.elk.layered.allowNonFlowPortsToSwitchSides",
    if node1_may_switch {
      "true"
    } else {
      "false"
    },
  )

  let node2 = @graph.create_node(Some(graph))
  @graph.node_set_dimensions(node2, 30.0, 30.0)
  @graph.node_set_layout_option_string_by_id(
    node2, "org.eclipse.elk.portConstraints", port_constraints,
  )

  let n2_north = create_port(Some(node2))
  port_set_dimensions(n2_north, 2.0, 2.0)
  port_set_location(n2_north, 15.0, -1.0)
  port_set_layout_option_string_by_id(
    n2_north, "org.eclipse.elk.port.side", "NORTH",
  )
  port_set_layout_option_string_by_id(
    n2_north,
    "org.eclipse.elk.layered.allowNonFlowPortsToSwitchSides",
    if node2_may_switch {
      "true"
    } else {
      "false"
    },
  )

  let n2_south = create_port(Some(node2))
  port_set_dimensions(n2_south, 2.0, 2.0)
  port_set_location(n2_south, 15.0, 30.0)
  port_set_layout_option_string_by_id(
    n2_south, "org.eclipse.elk.port.side", "SOUTH",
  )
  port_set_layout_option_string_by_id(
    n2_south,
    "org.eclipse.elk.layered.allowNonFlowPortsToSwitchSides",
    if node2_may_switch {
      "true"
    } else {
      "false"
    },
  )

  let e1 = create_edge(None)
  edge_add_source(e1, make_port_shape(n1_north))
  edge_add_target(e1, make_port_shape(n2_south))
  layered_test_update_containment(Some(e1))

  let e2 = create_edge(None)
  edge_add_source(e2, make_port_shape(n1_south))
  edge_add_target(e2, make_port_shape(n2_north))
  layered_test_update_containment(Some(e2))

  graph
}

///|
type AllowNonFlowPortsScenario = (String, Bool, Bool, Bool)

///|
fn allow_non_flow_ports_test_min(a : Double, b : Double) -> Double {
  if a < b {
    a
  } else {
    b
  }
}

///|
fn allow_non_flow_ports_test_max(a : Double, b : Double) -> Double {
  if a > b {
    a
  } else {
    b
  }
}

///|
fn allow_non_flow_ports_test_orientation(
  ax : Double,
  ay : Double,
  bx : Double,
  by : Double,
  cx : Double,
  cy : Double,
) -> Double {
  (bx - ax) * (cy - ay) - (by - ay) * (cx - ax)
}

///|
fn allow_non_flow_ports_test_on_segment(
  ax : Double,
  ay : Double,
  bx : Double,
  by : Double,
  cx : Double,
  cy : Double,
) -> Bool {
  let epsilon = 0.000000001
  cx >= allow_non_flow_ports_test_min(ax, bx) - epsilon &&
  cx <= allow_non_flow_ports_test_max(ax, bx) + epsilon &&
  cy >= allow_non_flow_ports_test_min(ay, by) - epsilon &&
  cy <= allow_non_flow_ports_test_max(ay, by) + epsilon
}

///|
fn allow_non_flow_ports_test_segments_intersect(
  ax : Double,
  ay : Double,
  bx : Double,
  by : Double,
  cx : Double,
  cy : Double,
  dx : Double,
  dy : Double,
) -> Bool {
  let o1 = allow_non_flow_ports_test_orientation(ax, ay, bx, by, cx, cy)
  let o2 = allow_non_flow_ports_test_orientation(ax, ay, bx, by, dx, dy)
  let o3 = allow_non_flow_ports_test_orientation(cx, cy, dx, dy, ax, ay)
  let o4 = allow_non_flow_ports_test_orientation(cx, cy, dx, dy, bx, by)

  let epsilon = 0.000000001
  let crosses = (
      (o1 > epsilon && o2 < -epsilon) || (o1 < -epsilon && o2 > epsilon)
    ) &&
    ((o3 > epsilon && o4 < -epsilon) || (o3 < -epsilon && o4 > epsilon))
  if crosses {
    return true
  }

  if o1.abs() <= epsilon &&
    allow_non_flow_ports_test_on_segment(ax, ay, bx, by, cx, cy) {
    return true
  }
  if o2.abs() <= epsilon &&
    allow_non_flow_ports_test_on_segment(ax, ay, bx, by, dx, dy) {
    return true
  }
  if o3.abs() <= epsilon &&
    allow_non_flow_ports_test_on_segment(cx, cy, dx, dy, ax, ay) {
    return true
  }
  if o4.abs() <= epsilon &&
    allow_non_flow_ports_test_on_segment(cx, cy, dx, dy, bx, by) {
    return true
  }
  false
}

///|
fn allow_non_flow_ports_test_edge_segments(
  edge : @graph.ElkEdge,
) -> Array[(Double, Double, Double, Double)] {
  let segments = []

  let sections = @graph.edge_sections(edge)
  if !sections.is_empty() {
    for section in sections {
      segments.push(
        (
          @graph.edge_section_start_x(section),
          @graph.edge_section_start_y(section),
          @graph.edge_section_end_x(section),
          @graph.edge_section_end_y(section),
        ),
      )
    }
    return segments
  }

  let point_of_shape = fn(
    shape : @graph.ElkConnectableShape,
  ) -> (Double, Double) {
    match shape {
      NodeShape(node) =>
        (
          @graph.node_x(node) + @graph.node_width(node) / 2.0,
          @graph.node_y(node) + @graph.node_height(node) / 2.0,
        )
      PortShape(port) =>
        match @graph.port_parent(port) {
          Some(parent) =>
            (
              @graph.node_x(parent) + port_x(port) + port_width(port) / 2.0,
              @graph.node_y(parent) + port_y(port) + port_height(port) / 2.0,
            )
          None => abort("port without parent")
        }
    }
  }

  for source in @graph.edge_sources(edge) {
    for target in @graph.edge_targets(edge) {
      let source_point = point_of_shape(source)
      let target_point = point_of_shape(target)
      segments.push(
        (source_point.0, source_point.1, target_point.0, target_point.1),
      )
    }
  }
  segments
}

///|
fn allow_non_flow_ports_test_edges_intersect(
  edge1 : @graph.ElkEdge,
  edge2 : @graph.ElkEdge,
) -> Bool {
  let segments1 = allow_non_flow_ports_test_edge_segments(edge1)
  let segments2 = allow_non_flow_ports_test_edge_segments(edge2)
  for segment1 in segments1 {
    for segment2 in segments2 {
      if allow_non_flow_ports_test_segments_intersect(
          segment1.0,
          segment1.1,
          segment1.2,
          segment1.3,
          segment2.0,
          segment2.1,
          segment2.2,
          segment2.3,
        ) {
        return true
      }
    }
  }
  false
}

///|
test "AllowNonFlowPortsToSwitchSides only switches if permitted" {
  reset_graph_model_for_test()
  allow_non_flow_ports_test_setup_plain_java_layout()

  let scenarios : Array[AllowNonFlowPortsScenario] = [
    ("FIXED_SIDE", false, false, true),
    ("FIXED_POS", true, true, true),
    ("FIXED_SIDE", true, false, false),
    ("FIXED_SIDE", false, true, false),
    ("FIXED_SIDE", true, true, false),
    ("FIXED_ORDER", true, true, false),
  ]
  for scenario in scenarios {
    let graph = allow_non_flow_ports_test_create_graph(
      scenario.0,
      scenario.1,
      scenario.2,
    )
    allow_non_flow_ports_test_layout(graph)

    assert_eq(
      @graph.node_get_string_property(graph, resolved_algorithm),
      "org.eclipse.elk.layered",
    )

    let edges = @graph.node_contained_edges(graph)
    assert_eq(edges.length(), 2)
    assert_eq(
      allow_non_flow_ports_test_edges_intersect(edges[0], edges[1]),
      scenario.3,
    )
  }
}
