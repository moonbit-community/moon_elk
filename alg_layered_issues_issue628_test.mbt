///|
fn issue628_test_setup_plain_java_layout() -> Unit {
  layout_meta_data_service_reset_for_test()
  plain_java_initialization_reset_for_test()
  plain_java_initialization_initialize_plain_java_layout()
}

///|
fn issue628_test_layout(graph : ElkNode) -> Unit {
  let resolver = new_layout_algorithm_resolver()
  apply_visitors(graph, [resolver.to_visitor()])
  let layout_engine = new_recursive_graph_layout_engine()
  layout_engine.layout(graph, new_null_elk_progress_monitor())
}

///|
fn issue628_test_assert_close(
  actual : Double,
  expected : Double,
  epsilon : Double,
) -> Unit {
  if (actual - expected).abs() > epsilon {
    abort("expected=\{expected}, actual=\{actual}, epsilon=\{epsilon}")
  }
}

///|
fn issue628_test_build_graph() -> (ElkNode, ElkNode, ElkNode) {
  let graph = create_graph()
  node_set_string_property(graph, algorithm, "org.eclipse.elk.layered")

  let l1 = create_node(Some(graph))
  node_set_string_property(l1, algorithm, "org.eclipse.elk.layered")
  node_set_string_property(l1, direction, "RIGHT")
  node_set_double_property(l1, spacing_node_node, 10.0)
  node_set_double_property(
    l1, layered_options_spacing_node_node_between_layers, 10.0,
  )

  let l2_1 = create_node(Some(l1))
  node_set_identifier(l2_1, "l2_1")
  node_set_dimensions(l2_1, 20.0, 20.0)
  let l2_2 = create_node(Some(l1))
  node_set_identifier(l2_2, "l2_2")
  node_set_dimensions(l2_2, 20.0, 20.0)

  let edge = create_edge(None)
  edge_add_source(edge, make_node_shape(l2_1))
  edge_add_target(edge, make_node_shape(l2_2))
  update_containment(Some(edge))

  (graph, l2_1, l2_2)
}

///|
fn issue628_test_layout_with_configurator(
  configure_hierarchical_greedy_switch : Bool,
  configure_greedy_switch : Bool,
) -> (ElkNode, ElkNode, ElkNode) {
  reset_graph_model_for_test()
  issue628_test_setup_plain_java_layout()

  let (graph, l2_1, l2_2) = issue628_test_build_graph()
  if configure_hierarchical_greedy_switch {
    node_set_string_property(
      graph, layered_options_crossing_minimization_greedy_switch_hierarchical_type,
      "TWO_SIDED",
    )
  }
  if configure_greedy_switch {
    node_set_string_property(
      graph, layered_options_crossing_minimization_greedy_switch_type, "TWO_SIDED",
    )
  }

  issue628_test_layout(graph)
  (graph, l2_1, l2_2)
}

///|
fn issue628_test_assert_sibling_alignment_and_spacing(
  l2_1 : ElkNode,
  l2_2 : ElkNode,
) -> Unit {
  let y1 = node_y(l2_1)
  let y2 = node_y(l2_2)
  let spacing = node_x(l2_2) - (node_x(l2_1) + node_width(l2_1))

  issue628_test_assert_close(y1, y2, 0.00001)
  issue628_test_assert_close(spacing, 10.0, 0.00001)
}

///|
test "Issue628 configureGreedySwitchHierarchical keeps sibling alignment and spacing" {
  let (_, l2_1, l2_2) = issue628_test_layout_with_configurator(true, false)
  issue628_test_assert_sibling_alignment_and_spacing(l2_1, l2_2)
}

///|
test "Issue628 unconfigureGreedySwitchHierarchical keeps sibling alignment and spacing" {
  let (_, l2_1, l2_2) = issue628_test_layout_with_configurator(false, false)
  issue628_test_assert_sibling_alignment_and_spacing(l2_1, l2_2)
}

///|
test "Issue628 configureGreedySwitch keeps sibling alignment and spacing" {
  let (_, l2_1, l2_2) = issue628_test_layout_with_configurator(false, true)
  issue628_test_assert_sibling_alignment_and_spacing(l2_1, l2_2)
}

///|
test "Issue628 unconfigureGreedySwitch keeps sibling alignment and spacing" {
  let (_, l2_1, l2_2) = issue628_test_layout_with_configurator(false, false)
  issue628_test_assert_sibling_alignment_and_spacing(l2_1, l2_2)
}
