///|
struct RecursiveLayoutGraphFixture {
  root : ElkNode
}

///|
fn new_recursive_layout_graph_fixture() -> RecursiveLayoutGraphFixture {
  let root = create_graph()
  let n1 = create_node(Some(root))
  node_set_dimensions(n1, 10.0, 10.0)
  let n2 = create_node(Some(root))
  node_set_dimensions(n2, 10.0, 10.0)
  { root, }
}

///|
fn init_layout_metadata_for_engine_test() -> Unit {
  layout_meta_data_service_reset_for_test()
  layout_meta_data_service_register_default_algorithms()
}

///|
test "RecursiveGraphLayoutEngine unresolved graph" {
  reset_graph_model_for_test()
  init_layout_metadata_for_engine_test()
  let graph = new_recursive_layout_graph_fixture()
  node_set_string_property(graph.root, algorithm, "org.eclipse.elk.box")
  let engine = new_recursive_graph_layout_engine()
  engine.layout(graph.root, new_basic_progress_monitor())
  assert_true(node_width(graph.root) > 0.0)
  assert_true(node_height(graph.root) > 0.0)
}

///|
test "RecursiveGraphLayoutEngine resolved graph" {
  reset_graph_model_for_test()
  init_layout_metadata_for_engine_test()
  let graph = new_recursive_layout_graph_fixture()
  node_set_string_property(
    graph.root,
    resolved_algorithm,
    "org.eclipse.elk.box",
  )
  let engine = new_recursive_graph_layout_engine()
  engine.layout(graph.root, new_basic_progress_monitor())
  assert_true(node_width(graph.root) > 0.0)
  assert_true(node_height(graph.root) > 0.0)
}

///|
test "panic RecursiveGraphLayoutEngine unknown algorithm id" {
  reset_graph_model_for_test()
  init_layout_metadata_for_engine_test()
  let graph = new_recursive_layout_graph_fixture()
  node_set_string_property(graph.root, algorithm, "foo.Bar")
  let engine = new_recursive_graph_layout_engine()
  engine.layout(graph.root, new_basic_progress_monitor())
}

///|
test "RecursiveGraphLayoutEngine empty algorithm id falls back to layered" {
  reset_graph_model_for_test()
  init_layout_metadata_for_engine_test()
  let graph = new_recursive_layout_graph_fixture()
  let engine = new_recursive_graph_layout_engine()
  engine.layout(graph.root, new_basic_progress_monitor())
  assert_eq(
    node_get_string_property(graph.root, resolved_algorithm),
    "org.eclipse.elk.layered",
  )
}
