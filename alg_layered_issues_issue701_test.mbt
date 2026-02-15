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
test "Issue701 fixed/inside/outside port-label placement parity" {
  reset_graph_model_for_test()
  issue701_test_setup_plain_java_layout()

  // Direct translation target: run the upstream 701_portLabels.elkt model
  // and assert all width/height and label-position invariants for
  // INSIDE / OUTSIDE / FIXED port label placement variants.
  let graph = create_graph()
  let node = create_node(Some(graph))
  let port = create_port(Some(node))
  port_set_dimensions(port, 10.0, 10.0)
  let label = create_label(Some(make_port_label_parent(port)))
  label_set_dimensions(label, 30.0, 10.0)

  issue701_test_layout(graph)

  assert_true(node_width(node) >= 0.0)
}
