///|
struct RecursiveLayoutGraphFixture {
  root : @graph.ElkNode
}

///|
fn new_recursive_layout_graph_fixture() -> RecursiveLayoutGraphFixture {
  let root = @graph.create_graph()
  let n1 = @graph.create_node(Some(root))
  @graph.node_set_dimensions(n1, 10.0, 10.0)
  let n2 = @graph.create_node(Some(root))
  @graph.node_set_dimensions(n2, 10.0, 10.0)
  { root, }
}

///|
fn init_layout_metadata_for_engine_test() -> Unit {
  ()
}

///|
test "RecursiveGraphLayoutEngine unresolved graph" {
  init_layout_metadata_for_engine_test()
  let graph = new_recursive_layout_graph_fixture()
  @graph.node_set_string_property(graph.root, algorithm, "org.eclipse.elk.box")
  let engine = new_recursive_graph_layout_engine(
    @elk_graph_json.new_layout_runtime(),
    new_layout_session(),
  )
  engine.layout(graph.root, new_basic_progress_monitor())
  assert_true(@graph.node_width(graph.root) > 0.0)
  assert_true(@graph.node_height(graph.root) > 0.0)
}

///|
test "RecursiveGraphLayoutEngine resolved graph" {
  init_layout_metadata_for_engine_test()
  let graph = new_recursive_layout_graph_fixture()
  @graph.node_set_string_property(
    graph.root,
    resolved_algorithm,
    "org.eclipse.elk.box",
  )
  let engine = new_recursive_graph_layout_engine(
    @elk_graph_json.new_layout_runtime(),
    new_layout_session(),
  )
  engine.layout(graph.root, new_basic_progress_monitor())
  assert_true(@graph.node_width(graph.root) > 0.0)
  assert_true(@graph.node_height(graph.root) > 0.0)
}

///|
test "RecursiveGraphLayoutEngine unknown algorithm reports runtime error" {
  init_layout_metadata_for_engine_test()
  let graph = new_recursive_layout_graph_fixture()
  @graph.node_set_string_property(graph.root, algorithm, "foo.Bar")
  let session = new_layout_session()
  let engine = new_recursive_graph_layout_engine(
    @elk_graph_json.new_layout_runtime(),
    session,
  )
  engine.layout(graph.root, new_basic_progress_monitor())
  let error = session.take_error_message()
  assert_eq(error is Some(_), true)
  if error is Some(message) {
    assert_eq(message.is_empty(), false)
  }
}

///|
test "RecursiveGraphLayoutEngine empty algorithm id falls back to layered" {
  init_layout_metadata_for_engine_test()
  let graph = new_recursive_layout_graph_fixture()
  let engine = new_recursive_graph_layout_engine(
    @elk_graph_json.new_layout_runtime(),
    new_layout_session(),
  )
  engine.layout(graph.root, new_basic_progress_monitor())
  assert_eq(
    @graph.node_get_string_property(graph.root, resolved_algorithm),
    "org.eclipse.elk.layered",
  )
}
