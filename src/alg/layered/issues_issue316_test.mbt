///|
fn issue316_test_setup_plain_java_layout() -> Unit {
  layout_meta_data_service_reset_for_test()
  plain_java_initialization_reset_for_test()
  plain_java_initialization_initialize_plain_java_layout()
}

///|
fn issue316_ports_overlap(left : @graph.ElkPort, right : @graph.ElkPort) -> Bool {
  let left_x = port_x(left)
  let left_y = port_y(left)
  let right_x = port_x(right)
  let right_y = port_y(right)
  left_x < right_x + port_width(right) &&
  left_x + port_width(left) > right_x &&
  left_y < right_y + port_height(right) &&
  left_y + port_height(left) > right_y
}

///|
fn issue316_any_port_overlap(node : @graph.ElkNode) -> Bool {
  let ports = @graph.node_ports(node)
  for i = 0; i < ports.length(); i = i + 1 {
    for j = i + 1; j < ports.length(); j = j + 1 {
      if issue316_ports_overlap(ports[i], ports[j]) {
        return true
      }
    }
  }
  false
}

///|
fn issue316_label_inside_node(label : @graph.ElkLabel, node : @graph.ElkNode) -> Bool {
  @graph.label_x(label) >= 0.0 &&
  @graph.label_y(label) >= 0.0 &&
  @graph.label_x(label) + @graph.label_width(label) <= @graph.node_width(node) &&
  @graph.label_y(label) + @graph.label_height(label) <= @graph.node_height(node)
}

///|
fn issue316_test_create_graph() -> @graph.ElkNode {
  let graph = create_graph()
  let parent = @graph.create_node(Some(graph))
  @graph.node_set_dimensions(parent, 120.0, 80.0)

  let child = @graph.create_node(Some(parent))
  @graph.node_set_dimensions(child, 40.0, 30.0)

  let parent_port_a = create_port(Some(parent))
  port_set_location(parent_port_a, 2.0, 2.0)
  port_set_dimensions(parent_port_a, 10.0, 10.0)
  let parent_port_b = create_port(Some(parent))
  port_set_location(parent_port_b, 100.0, 60.0)
  port_set_dimensions(parent_port_b, 10.0, 10.0)

  let parent_label = @graph.create_label(Some(make_node_label_parent(parent)))
  @graph.label_set_text(parent_label, "parent")
  @graph.label_set_location(parent_label, 5.0, 5.0)
  @graph.label_set_dimensions(parent_label, 20.0, 10.0)

  graph
}

///|
fn issue316_test_build_and_layout_graph() -> @graph.ElkNode {
  reset_graph_model_for_test()
  issue316_test_setup_plain_java_layout()

  let graph = issue316_test_create_graph()
  let resolver = new_layout_algorithm_resolver()
  apply_visitors(graph, [resolver.to_visitor()])
  let layout_engine = new_recursive_graph_layout_engine()
  layout_engine.layout(graph, @core.new_null_elk_progress_monitor())
  graph
}

///|
test "Issue316 ensure ports do not @common.overlap" {
  let graph = issue316_test_build_and_layout_graph()
  for node in graph_test_utils_all_nodes(graph, false) {
    assert_false(issue316_any_port_overlap(node))
  }
}

///|
test "Issue316 ensure hierarchical node labels stay inside" {
  let graph = issue316_test_build_and_layout_graph()
  for node in graph_test_utils_all_nodes(graph, false) {
    if !@graph.node_children(node).is_empty() {
      for label in node_labels(node) {
        assert_true(issue316_label_inside_node(label, node))
      }
    }
  }
}
