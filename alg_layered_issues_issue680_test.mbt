///|
fn issue680_test_setup_plain_java_layout() -> Unit {
  layout_meta_data_service_reset_for_test()
  plain_java_initialization_reset_for_test()
  plain_java_initialization_initialize_plain_java_layout()
}

///|
struct Issue680TestGraph {
  graph : ElkNode
  parent : ElkNode
  child : ElkNode
}

///|
fn issue680_test_graph() -> Issue680TestGraph {
  let graph = create_graph()
  node_set_string_property(graph, algorithm, "org.eclipse.elk.layered")
  node_set_string_property(graph, edge_routing, "ORTHOGONAL")
  node_set_string_property(graph, direction, "DOWN")

  let parent = create_node(Some(graph))
  node_set_string_property(parent, algorithm, "org.eclipse.elk.layered")
  node_set_string_property(parent, edge_routing, "ORTHOGONAL")
  node_set_string_property(parent, direction, "DOWN")

  let p1 = create_port(Some(parent))
  port_set_dimensions(p1, 15.0, 165.0)
  port_set_layout_option_string_by_id(
    p1, "org.eclipse.elk.port.borderOffset", "-20.0",
  )
  let p2 = create_port(Some(parent))
  port_set_dimensions(p2, 15.0, 166.0)
  port_set_layout_option_string_by_id(
    p2, "org.eclipse.elk.port.borderOffset", "-22.0",
  )

  let child = create_node(Some(parent))
  node_set_dimensions(child, 40.265625, 75.5)
  let child_p1 = create_port(Some(child))
  port_set_dimensions(child_p1, 15.0, 33.0)
  port_set_layout_option_string_by_id(
    child_p1, "org.eclipse.elk.port.borderOffset", "-8.0",
  )
  let child_p2 = create_port(Some(child))
  port_set_dimensions(child_p2, 15.0, 34.0)
  port_set_layout_option_string_by_id(
    child_p2, "org.eclipse.elk.port.borderOffset", "-8.0",
  )

  let edge1 = create_edge(None)
  edge_add_source(edge1, make_port_shape(p1))
  edge_add_target(edge1, make_port_shape(child_p1))
  update_containment(Some(edge1))

  let edge2 = create_edge(None)
  edge_add_source(edge2, make_port_shape(child_p2))
  edge_add_target(edge2, make_port_shape(p2))
  update_containment(Some(edge2))

  { graph, parent, child }
}

///|
#skip
test "Issue680 parent and child Y positions stay stable" {
  reset_graph_model_for_test()
  issue680_test_setup_plain_java_layout()
  let test_graph = issue680_test_graph()

  let layout_engine = new_recursive_graph_layout_engine()
  layout_engine.layout(test_graph.graph, new_null_elk_progress_monitor())

  let epsilon = 0.00001
  assert_true((node_y(test_graph.parent) - 157.0).abs() <= epsilon)
  assert_true((node_y(test_graph.child) - 57.0).abs() <= epsilon)
}
