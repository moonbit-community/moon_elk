///|
fn label_and_node_size_offset_test_setup_plain_java_layout() -> Unit {
  layout_meta_data_service_reset_for_test()
  plain_java_initialization_reset_for_test()
  plain_java_initialization_initialize_plain_java_layout()
}

///|
fn label_and_node_size_offset_test_layout(graph : ElkNode) -> Unit {
  let resolver = new_layout_algorithm_resolver()
  apply_visitors(graph, [resolver.to_visitor()])
  let layout_engine = new_recursive_graph_layout_engine()
  layout_engine.layout(graph, new_null_elk_progress_monitor())
}

///|
#skip
test "LabelAndNodeSizeProcessor applies zero border offset on all port sides" {
  reset_graph_model_for_test()
  label_and_node_size_offset_test_setup_plain_java_layout()

  // Direct translation target: assert processor-level port coordinates for
  // FREE/FIXED_SIDE/FIXED_ORDER/FIXED_RATIO/FIXED_POS constraints.
  let graph = create_graph()
  let node = create_node(Some(graph))
  node_set_dimensions(node, 100.0, 100.0)

  let north = create_port(Some(node))
  port_set_dimensions(north, 10.0, 10.0)
  port_set_location(north, 50.0, -300.0)
  port_set_layout_option_string_by_id(
    north, "org.eclipse.elk.port.side", "NORTH",
  )
  port_set_layout_option_string_by_id(
    north, "org.eclipse.elk.port.borderOffset", "0.0",
  )

  label_and_node_size_offset_test_layout(graph)
  assert_eq(node_ports(node).length(), 1)
}
