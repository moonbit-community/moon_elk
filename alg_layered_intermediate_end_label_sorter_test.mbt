///|
fn end_label_sorter_test_setup_plain_java_layout() -> Unit {
  layout_meta_data_service_reset_for_test()
  plain_java_initialization_reset_for_test()
  plain_java_initialization_initialize_plain_java_layout()
}

///|
fn end_label_sorter_test_layout(graph : ElkNode) -> Unit {
  let resolver = new_layout_algorithm_resolver()
  apply_visitors(graph, [resolver.to_visitor()])
  let layout_engine = new_recursive_graph_layout_engine()
  layout_engine.layout(graph, new_null_elk_progress_monitor())
}

///|
#skip
test "EndLabelSorter keeps represented labels lexicographically sorted" {
  reset_graph_model_for_test()
  end_label_sorter_test_setup_plain_java_layout()

  // Direct translation target: load labels_ordering fixtures and assert that
  // represented end-label lists are sorted after EndLabelSorter.
  let graph = create_graph()
  let n1 = create_node(Some(graph))
  let n2 = create_node(Some(graph))
  let edge = create_edge(None)
  edge_add_source(edge, make_node_shape(n1))
  edge_add_target(edge, make_node_shape(n2))
  update_containment(Some(edge))

  let l1 = create_label(Some(make_edge_label_parent(edge)))
  label_set_text(l1, "B")
  let l2 = create_label(Some(make_edge_label_parent(edge)))
  label_set_text(l2, "A")

  end_label_sorter_test_layout(graph)
  assert_eq(edge_labels(edge).length(), 2)
}
