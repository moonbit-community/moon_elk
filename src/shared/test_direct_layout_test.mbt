///|
fn shared_direct_layout_test_setup_plain_java_layout() -> Unit {
  layout_meta_data_service_reset_for_test()
  plain_java_initialization_reset_for_test()
  plain_java_initialization_initialize_plain_java_layout()
}

///|
fn shared_direct_layout_test_add_layered_options(parent_node : ElkNode) -> Unit {
  node_set_string_property(parent_node, algorithm, "org.eclipse.elk.layered")
  node_set_string_property(parent_node, direction, "RIGHT")

  for child_node in node_children(parent_node) {
    node_set_dimensions(child_node, 30.0, 30.0)
    node_set_string_set_property(child_node, node_size_constraints, [
      "FIXED_SIZE",
    ])
    node_set_string_property(child_node, port_constraints, "FIXED_POS")

    let ports = node_ports(child_node)
    let mut index = 0
    let mut child_name = ""
    if !node_labels(child_node).is_empty() {
      child_name = label_text(node_labels(child_node)[0])
    }
    for port in ports {
      index += 1
      let y = index.to_double() * 30.0 / (ports.length().to_double() + 1.0)
      if child_name == "node1" {
        port_set_location(port, 30.0, y)
        port_set_layout_option_string_by_id(port, port_side.get_id(), "EAST")
      } else {
        port_set_location(port, 0.0, y)
        port_set_layout_option_string_by_id(port, port_side.get_id(), "WEST")
      }
    }
  }
}

///|
test "DirectLayoutTest ELK layered sets positive coordinates" {
  reset_graph_model_for_test()
  shared_direct_layout_test_setup_plain_java_layout()

  let parent_node = graph_test_utils_create_simple_graph()
  shared_direct_layout_test_add_layered_options(parent_node)

  let progress_monitor = new_basic_progress_monitor()
  let layout_provider = new_abstract_layout_provider((layout_graph, monitor) => {
    let layout_engine = new_recursive_graph_layout_engine()
    layout_engine.layout(layout_graph, monitor)
  })
  layout_provider.initialize(None)
  layout_provider.layout(parent_node, progress_monitor)

  for child in node_children(parent_node) {
    assert_true(node_x(child) > 0.0)
    assert_true(node_y(child) > 0.0)
  }
  assert_true(progress_monitor.get_execution_time() >= 0.0)
}
