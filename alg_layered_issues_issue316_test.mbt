///|
fn issue316_test_setup_plain_java_layout() -> Unit {
  layout_meta_data_service_reset_for_test()
  plain_java_initialization_reset_for_test()
  plain_java_initialization_initialize_plain_java_layout()
}

///|
fn issue316_ports_overlap(left : ElkPort, right : ElkPort) -> Bool {
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
fn issue316_any_port_overlap(node : ElkNode) -> Bool {
  let ports = node_ports(node)
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
fn issue316_label_inside_node(label : ElkLabel, node : ElkNode) -> Bool {
  label_x(label) >= 0.0 &&
  label_y(label) >= 0.0 &&
  label_x(label) + label_width(label) <= node_width(node) &&
  label_y(label) + label_height(label) <= node_height(node)
}

///|
test "Issue316 ports do not overlap and hierarchical labels stay inside" {
  reset_graph_model_for_test()
  issue316_test_setup_plain_java_layout()

  let graph = create_graph()
  let parent = create_node(Some(graph))
  node_set_dimensions(parent, 120.0, 80.0)

  let child = create_node(Some(parent))
  node_set_dimensions(child, 40.0, 30.0)

  let parent_port_a = create_port(Some(parent))
  port_set_location(parent_port_a, 2.0, 2.0)
  port_set_dimensions(parent_port_a, 10.0, 10.0)
  let parent_port_b = create_port(Some(parent))
  port_set_location(parent_port_b, 100.0, 60.0)
  port_set_dimensions(parent_port_b, 10.0, 10.0)

  let parent_label = create_label(Some(make_node_label_parent(parent)))
  label_set_text(parent_label, "parent")
  label_set_location(parent_label, 5.0, 5.0)
  label_set_dimensions(parent_label, 20.0, 10.0)

  let resolver = new_layout_algorithm_resolver()
  apply_visitors(graph, [resolver.to_visitor()])
  let layout_engine = new_recursive_graph_layout_engine()
  layout_engine.layout(graph, new_null_elk_progress_monitor())

  assert_false(issue316_any_port_overlap(parent))

  if !node_children(parent).is_empty() {
    for label in node_labels(parent) {
      assert_true(issue316_label_inside_node(label, parent))
    }
  }
}
