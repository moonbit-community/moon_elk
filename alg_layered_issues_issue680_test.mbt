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
  p1 : ElkPort
  p2 : ElkPort
  child_p1 : ElkPort
  child_p2 : ElkPort
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

  { graph, parent, child, p1, p2, child_p1, child_p2 }
}

///|
test "Issue680 parent and child Y positions stay stable" {
  reset_graph_model_for_test()
  issue680_test_setup_plain_java_layout()
  let test_graph = issue680_test_graph()

  let layout_engine = new_recursive_graph_layout_engine()
  layout_engine.layout(test_graph.graph, new_null_elk_progress_monitor())

  let epsilon = 0.00001
  let parent_y = node_y(test_graph.parent)
  let parent_x = node_x(test_graph.parent)
  let child_y = node_y(test_graph.child)
  let child_x = node_x(test_graph.child)
  let child_w = node_width(test_graph.child)
  let child_h = node_height(test_graph.child)
  let parent_w = node_width(test_graph.parent)
  let parent_h = node_height(test_graph.parent)
  let graph_w = node_width(test_graph.graph)
  let graph_h = node_height(test_graph.graph)
  let graph_padding = node_get_string_property(test_graph.graph, padding)
  let parent_padding = node_get_string_property(test_graph.parent, padding)
  let child_padding = node_get_string_property(test_graph.child, padding)
  let p1_xy = "(\{port_x(test_graph.p1)},\{port_y(test_graph.p1)})"
  let p2_xy = "(\{port_x(test_graph.p2)},\{port_y(test_graph.p2)})"
  let cp1_xy = "(\{port_x(test_graph.child_p1)},\{port_y(test_graph.child_p1)})"
  let cp2_xy = "(\{port_x(test_graph.child_p2)},\{port_y(test_graph.child_p2)})"
  let p1_side = match
    port_layout_option_string_value(test_graph.p1, "org.eclipse.elk.port.side") {
    Some(value) => value
    None => "NONE"
  }
  let p2_side = match
    port_layout_option_string_value(test_graph.p2, "org.eclipse.elk.port.side") {
    Some(value) => value
    None => "NONE"
  }
  assert_true(
    (parent_y - 157.0).abs() <= epsilon && (child_y - 57.0).abs() <= epsilon,
    msg="parent=(\{parent_x},\{parent_y}) expected_y=157.0; child=(\{child_x},\{child_y}) expected_y=57.0; child_size=(\{child_w},\{child_h}); parent_size=(\{parent_w},\{parent_h}); graph_size=(\{graph_w},\{graph_h}); graph_padding=\{graph_padding}; parent_padding=\{parent_padding}; child_padding=\{child_padding}; p1=\{p1_xy}; p2=\{p2_xy}; child_p1=\{cp1_xy}; child_p2=\{cp2_xy}; p1_side=\{p1_side}; p2_side=\{p2_side}",
  )
}
