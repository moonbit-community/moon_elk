///|
fn allow_non_flow_ports_test_setup_plain_java_layout() -> Unit {
  layout_meta_data_service_reset_for_test()
  plain_java_initialization_reset_for_test()
  plain_java_initialization_initialize_plain_java_layout()
}

///|
fn allow_non_flow_ports_test_layout(graph : ElkNode) -> Unit {
  let resolver = new_layout_algorithm_resolver()
  apply_visitors(graph, [resolver.to_visitor()])
  let layout_engine = new_recursive_graph_layout_engine()
  layout_engine.layout(graph, new_null_elk_progress_monitor())
}

///|
fn allow_non_flow_ports_test_create_graph(
  port_constraints : String,
  node1_may_switch : Bool,
  node2_may_switch : Bool,
) -> ElkNode {
  let graph = create_graph()

  let node1 = create_node(Some(graph))
  node_set_dimensions(node1, 30.0, 30.0)
  node_set_layout_option_string_by_id(
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

  let node2 = create_node(Some(graph))
  node_set_dimensions(node2, 30.0, 30.0)
  node_set_layout_option_string_by_id(
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
  update_containment(Some(e1))

  let e2 = create_edge(None)
  edge_add_source(e2, make_port_shape(n1_south))
  edge_add_target(e2, make_port_shape(n2_north))
  update_containment(Some(e2))

  graph
}

///|
test "AllowNonFlowPortsToSwitchSides basic crossing scenarios route edges" {
  reset_graph_model_for_test()
  allow_non_flow_ports_test_setup_plain_java_layout()

  let fixed_side = allow_non_flow_ports_test_create_graph(
    "FIXED_SIDE", false, false,
  )
  allow_non_flow_ports_test_layout(fixed_side)
  assert_eq(node_contained_edges(fixed_side).length(), 2)
  assert_eq(
    node_get_string_property(fixed_side, resolved_algorithm),
    "org.eclipse.elk.layered",
  )

  let one_switch = allow_non_flow_ports_test_create_graph(
    "FIXED_SIDE", true, false,
  )
  allow_non_flow_ports_test_layout(one_switch)
  assert_eq(node_contained_edges(one_switch).length(), 2)
  assert_eq(
    node_get_string_property(one_switch, resolved_algorithm),
    "org.eclipse.elk.layered",
  )
}
