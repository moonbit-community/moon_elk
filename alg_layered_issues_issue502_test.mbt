///|
fn issue502_test_setup_plain_java_layout() -> Unit {
  layout_meta_data_service_reset_for_test()
  plain_java_initialization_reset_for_test()
  plain_java_initialization_initialize_plain_java_layout()
}

///|
fn issue502_test_layout(graph : ElkNode) -> Unit {
  let resolver = new_layout_algorithm_resolver()
  apply_visitors(graph, [resolver.to_visitor()])
  let layout_engine = new_recursive_graph_layout_engine()
  layout_engine.layout(graph, new_null_elk_progress_monitor())
}

///|
fn issue502_test_large_enough(node : ElkNode) -> Bool {
  let mut required_width = 0.0
  let mut required_height = 0.0

  for child in node_children(node) {
    let child_right = node_x(child) + node_width(child)
    let child_bottom = node_y(child) + node_height(child)
    if child_right > required_width {
      required_width = child_right
    }
    if child_bottom > required_height {
      required_height = child_bottom
    }
  }

  for edge in node_contained_edges(node) {
    for section in edge_sections(edge) {
      if edge_section_start_x(section) > required_width {
        required_width = edge_section_start_x(section)
      }
      if edge_section_end_x(section) > required_width {
        required_width = edge_section_end_x(section)
      }
      if edge_section_start_y(section) > required_height {
        required_height = edge_section_start_y(section)
      }
      if edge_section_end_y(section) > required_height {
        required_height = edge_section_end_y(section)
      }
    }
  }

  node_width(node) >= required_width && node_height(node) >= required_height
}

///|
test "Issue502 compound nodes stay large enough for children and edge routes" {
  reset_graph_model_for_test()
  issue502_test_setup_plain_java_layout()

  let graph = create_graph()
  let compound = create_node(Some(graph))
  node_set_dimensions(compound, 200.0, 120.0)

  let child_a = create_node(Some(compound))
  node_set_dimensions(child_a, 40.0, 30.0)
  node_set_location(child_a, 20.0, 30.0)

  let child_b = create_node(Some(compound))
  node_set_dimensions(child_b, 40.0, 30.0)
  node_set_location(child_b, 120.0, 30.0)

  let edge = create_edge(None)
  edge_add_source(edge, make_node_shape(child_a))
  edge_add_target(edge, make_node_shape(child_b))
  update_containment(Some(edge))

  issue502_test_layout(graph)

  assert_true(issue502_test_large_enough(compound))
}
