///|
fn issue455_test_setup_plain_java_layout() -> Unit {
  layout_meta_data_service_reset_for_test()
  plain_java_initialization_reset_for_test()
  plain_java_initialization_initialize_plain_java_layout()
}

///|
fn issue455_test_layout(graph : ElkNode) -> Unit {
  let resolver = new_layout_algorithm_resolver()
  apply_visitors(graph, [resolver.to_visitor()])
  let layout_engine = new_recursive_graph_layout_engine()
  layout_engine.layout(graph, new_null_elk_progress_monitor())
}

///|
#skip
test "Issue455 hierarchical child nodes stay in one layer" {
  reset_graph_model_for_test()
  issue455_test_setup_plain_java_layout()

  let graph = create_graph()
  let compound = create_node(Some(graph))
  node_set_dimensions(compound, 200.0, 120.0)

  let child_a = create_node(Some(compound))
  node_set_dimensions(child_a, 40.0, 30.0)
  let child_b = create_node(Some(compound))
  node_set_dimensions(child_b, 40.0, 30.0)

  issue455_test_layout(graph)

  let children = node_children(compound)
  if children.length() > 1 {
    let mut min_x = node_x(children[0])
    let mut max_x = node_x(children[0])
    for child in children {
      if node_x(child) < min_x {
        min_x = node_x(child)
      }
      if node_x(child) > max_x {
        max_x = node_x(child)
      }
    }
    assert_true(max_x - min_x <= 0.5)
  }
}
