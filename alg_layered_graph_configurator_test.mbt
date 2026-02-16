///|
fn graph_configurator_test_graph(layerless_node_count : Int) -> LGraph {
  let graph = new_l_graph()
  for _ in 0..<layerless_node_count {
    let node = new_l_node(graph=Some(graph))
    graph.get_layerless_nodes().push(node)
  }
  graph
}

///|
let graph_configurator_test_double_eq_epsilon = 0.00001

///|
fn graph_configurator_test_set_non_hierarchical_defaults(
  graph : LGraph,
) -> Unit {
  graph.set_property_string(
    layered_options_hierarchy_handling, "SEPARATE_CHILDREN",
  )
  graph.set_property_string(
    layered_options_crossing_minimization_greedy_switch_type, "TWO_SIDED",
  )
  graph.set_property_bool(
    layered_options_crossing_minimization_semi_interactive, false,
  )
  graph.set_property_string(
    layered_options_crossing_minimization_strategy, "LAYER_SWEEP",
  )
}

///|
test "graph configurator activates greedy switch with non-hierarchical defaults" {
  let graph = graph_configurator_test_graph(2)
  graph_configurator_test_set_non_hierarchical_defaults(graph)
  graph.set_property_int(
    layered_options_crossing_minimization_greedy_switch_activation_threshold, 40,
  )

  assert_true(graph_configurator_activate_greedy_switch_for(graph))
}

///|
test "graph configurator deactivates greedy switch when threshold does not exceed graph size" {
  let graph = graph_configurator_test_graph(2)
  graph_configurator_test_set_non_hierarchical_defaults(graph)
  graph.set_property_int(
    layered_options_crossing_minimization_greedy_switch_activation_threshold, 2,
  )

  assert_false(graph_configurator_activate_greedy_switch_for(graph))
}

///|
test "graph configurator activation threshold zero forces activation" {
  let graph = graph_configurator_test_graph(10)
  graph_configurator_test_set_non_hierarchical_defaults(graph)
  graph.set_property_int(
    layered_options_crossing_minimization_greedy_switch_activation_threshold, 0,
  )

  assert_true(graph_configurator_activate_greedy_switch_for(graph))
}

///|
test "graph configurator deactivates greedy switch for semi-interactive cross minimization" {
  let graph = graph_configurator_test_graph(2)
  graph_configurator_test_set_non_hierarchical_defaults(graph)
  graph.set_property_bool(
    layered_options_crossing_minimization_semi_interactive, true,
  )
  graph.set_property_int(
    layered_options_crossing_minimization_greedy_switch_activation_threshold, 40,
  )

  assert_false(graph_configurator_activate_greedy_switch_for(graph))
}

///|
test "graph configurator deactivates greedy switch for interactive strategy" {
  let graph = graph_configurator_test_graph(2)
  graph_configurator_test_set_non_hierarchical_defaults(graph)
  graph.set_property_string(
    layered_options_crossing_minimization_strategy, "INTERACTIVE",
  )
  graph.set_property_int(
    layered_options_crossing_minimization_greedy_switch_activation_threshold, 40,
  )

  assert_false(graph_configurator_activate_greedy_switch_for(graph))
}

///|
test "graph configurator uses hierarchical greedy-switch option only on root graph" {
  let root_graph = graph_configurator_test_graph(2)
  root_graph.set_property_string(
    layered_options_hierarchy_handling, "INCLUDE_CHILDREN",
  )
  root_graph.set_property_string(
    layered_options_crossing_minimization_greedy_switch_hierarchical_type, "ONE_SIDED",
  )
  assert_true(graph_configurator_activate_greedy_switch_for(root_graph))

  let nested_graph = graph_configurator_test_graph(2)
  nested_graph.set_property_string(
    layered_options_hierarchy_handling, "INCLUDE_CHILDREN",
  )
  nested_graph.set_property_string(
    layered_options_crossing_minimization_greedy_switch_hierarchical_type, "ONE_SIDED",
  )
  nested_graph.set_parent_node(Some(new_l_node()))
  assert_false(graph_configurator_activate_greedy_switch_for(nested_graph))
}

///|
test "graph configurator deactivates hierarchical greedy switch when type is off" {
  let graph = graph_configurator_test_graph(2)
  graph.set_property_string(
    layered_options_hierarchy_handling, "INCLUDE_CHILDREN",
  )
  graph.set_property_string(
    layered_options_crossing_minimization_greedy_switch_hierarchical_type, "OFF",
  )

  assert_false(graph_configurator_activate_greedy_switch_for(graph))
}

///|
test "graph configurator enforces minimum edge spacing" {
  let graph = graph_configurator_test_graph(0)
  graph.set_property_double(spacing_edge_edge, 1.0)
  graph_configurator_enforce_min_edge_spacing(graph)
  assert_double_eq(
    graph.get_property_double(spacing_edge_edge),
    2.0,
    graph_configurator_test_double_eq_epsilon,
  )

  graph.set_property_double(spacing_edge_edge, 3.5)
  graph_configurator_enforce_min_edge_spacing(graph)
  assert_double_eq(
    graph.get_property_double(spacing_edge_edge),
    3.5,
    graph_configurator_test_double_eq_epsilon,
  )
}

///|
test "graph configurator enforces direction for undefined values" {
  let graph = graph_configurator_test_graph(0)
  graph.set_property_double(aspect_ratio, 2.0)
  graph_configurator_enforce_direction(graph)
  assert_eq(graph.get_property_string(direction), "RIGHT")

  graph.set_property_string(direction, "UNDEFINED")
  graph.set_property_double(aspect_ratio, 0.5)
  graph_configurator_enforce_direction(graph)
  assert_eq(graph.get_property_string(direction), "DOWN")
}

///|
test "graph configurator keeps explicit direction" {
  let graph = graph_configurator_test_graph(0)
  graph.set_property_string(direction, "LEFT")
  graph.set_property_double(aspect_ratio, 10.0)
  graph_configurator_enforce_direction(graph)

  assert_eq(graph.get_property_string(direction), "LEFT")
}

///|
test "graph configurator defaults favor-straight-edges from edge routing" {
  let orthogonal_graph = graph_configurator_test_graph(0)
  orthogonal_graph.set_property_string(edge_routing, "ORTHOGONAL")
  graph_configurator_default_favor_straight_edges(orthogonal_graph)
  assert_true(
    orthogonal_graph.get_property_bool(
      layered_options_node_placement_favor_straight_edges,
    ),
  )

  let polyline_graph = graph_configurator_test_graph(0)
  polyline_graph.set_property_string(edge_routing, "POLYLINE")
  graph_configurator_default_favor_straight_edges(polyline_graph)
  assert_false(
    polyline_graph.get_property_bool(
      layered_options_node_placement_favor_straight_edges,
    ),
  )
}

///|
test "graph configurator preserves explicit favor-straight-edges value" {
  let explicit_true = graph_configurator_test_graph(0)
  explicit_true.set_property_string(edge_routing, "POLYLINE")
  explicit_true.set_property_bool(
    layered_options_node_placement_favor_straight_edges, true,
  )
  graph_configurator_default_favor_straight_edges(explicit_true)
  assert_true(
    explicit_true.get_property_bool(
      layered_options_node_placement_favor_straight_edges,
    ),
  )

  let explicit_false = graph_configurator_test_graph(0)
  explicit_false.set_property_string(edge_routing, "ORTHOGONAL")
  explicit_false.set_property_bool(
    layered_options_node_placement_favor_straight_edges, false,
  )
  graph_configurator_default_favor_straight_edges(explicit_false)
  assert_false(
    explicit_false.get_property_bool(
      layered_options_node_placement_favor_straight_edges,
    ),
  )
}

///|
test "graph configurator copies original port constraints recursively" {
  let graph = graph_configurator_test_graph(0)

  let layerless_node = new_l_node(graph=Some(graph))
  layerless_node.set_property_string(port_constraints, "FIXED_ORDER")
  graph.get_layerless_nodes().push(layerless_node)

  let layer = new_layer(graph)
  graph.get_layers().push(layer)
  let layered_node = new_l_node(graph=Some(graph))
  layered_node.set_property_string(port_constraints, "FIXED_SIDE")
  layered_node.set_layer(Some(layer))

  let container_node = new_l_node(graph=Some(graph))
  container_node.set_property_string(port_constraints, "FREE")
  graph.get_layerless_nodes().push(container_node)

  let nested_graph = new_l_graph()
  container_node.set_nested_graph(Some(nested_graph))
  let nested_node = new_l_node(graph=Some(nested_graph))
  nested_graph.get_layerless_nodes().push(nested_node)

  graph_configurator_copy_port_constraints(graph)

  assert_eq(
    layerless_node.get_property_string(
      internal_properties_original_port_constraints,
    ),
    "FIXED_ORDER",
  )
  assert_eq(
    layered_node.get_property_string(
      internal_properties_original_port_constraints,
    ),
    "FIXED_SIDE",
  )
  assert_eq(
    container_node.get_property_string(
      internal_properties_original_port_constraints,
    ),
    "FREE",
  )
  assert_eq(
    nested_node.get_property_string(
      internal_properties_original_port_constraints,
    ),
    "UNDEFINED",
  )
}
