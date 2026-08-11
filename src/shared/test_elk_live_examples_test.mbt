///|
fn shared_elk_live_examples_test_setup_plain_java_layout() -> Unit {

}

///|
fn shared_elk_live_examples_test_graphs() -> Array[ElkNode] raise {
  [
    graph_test_utils_create_simple_graph(),
    graph_test_utils_create_hierarchical_graph(),
  ]
}

///|
test "ElkLiveExamplesTest no exception on example graphs" {
  shared_elk_live_examples_test_setup_plain_java_layout()

  for graph in shared_elk_live_examples_test_graphs() {
    node_set_string_property(graph, algorithm, "org.eclipse.elk.layered")
    let layout_engine = new_recursive_graph_layout_engine()
    layout_engine.layout(graph, new_basic_progress_monitor())
  }
  assert_true(true)
}
