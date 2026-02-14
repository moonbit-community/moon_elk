///|
fn issue603_test_setup_plain_java_layout() -> Unit {
  layout_meta_data_service_reset_for_test()
  plain_java_initialization_reset_for_test()
  plain_java_initialization_initialize_plain_java_layout()
}

///|
fn issue603_test_layout(graph : ElkNode) -> Unit {
  let resolver = new_layout_algorithm_resolver()
  apply_visitors(graph, [resolver.to_visitor()])
  let layout_engine = new_recursive_graph_layout_engine()
  layout_engine.layout(graph, new_null_elk_progress_monitor())
}

///|
fn issue603_rectangles_overlap(
  left_x : Double,
  left_y : Double,
  left_w : Double,
  left_h : Double,
  right_x : Double,
  right_y : Double,
  right_w : Double,
  right_h : Double,
) -> Bool {
  left_x < right_x + right_w &&
  left_x + left_w > right_x &&
  left_y < right_y + right_h &&
  left_y + left_h > right_y
}

///|
#skip
test "Issue603 no overlap between compound labels and child nodes" {
  reset_graph_model_for_test()
  issue603_test_setup_plain_java_layout()

  let graph = create_graph()
  let parent = create_node(Some(graph))
  node_set_dimensions(parent, 180.0, 120.0)

  let parent_label = create_label(Some(make_node_label_parent(parent)))
  label_set_text(parent_label, "Parent")
  label_set_dimensions(parent_label, 60.0, 16.0)
  label_set_location(parent_label, 60.0, 2.0)

  let child = create_node(Some(parent))
  node_set_dimensions(child, 80.0, 40.0)
  node_set_location(child, 50.0, 50.0)

  issue603_test_layout(graph)

  assert_false(
    issue603_rectangles_overlap(
      label_x(parent_label),
      label_y(parent_label),
      label_width(parent_label),
      label_height(parent_label),
      node_x(child),
      node_y(child),
      node_width(child),
      node_height(child),
    ),
  )
}
