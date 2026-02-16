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
