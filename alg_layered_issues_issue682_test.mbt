///|
fn issue682_test_setup_plain_java_layout() -> Unit {
  layout_meta_data_service_reset_for_test()
  plain_java_initialization_reset_for_test()
  plain_java_initialization_initialize_plain_java_layout()
}

///|
struct Issue682TestGraph {
  graph : ElkNode
  parent : ElkNode
  label : ElkLabel
}

///|
fn issue682_test_graph(layout_direction : String) -> Issue682TestGraph {
  let graph = create_graph()
  node_set_string_property(graph, algorithm, "org.eclipse.elk.layered")
  node_set_string_property(graph, edge_routing, "ORTHOGONAL")
  node_set_string_property(graph, direction, layout_direction)
  node_set_layout_option_string_by_id(
    graph, "org.eclipse.elk.nodeLabels.padding", "[top=21,right=32,bottom=43,left=54]",
  )

  let parent = create_node(Some(graph))
  node_set_string_set_property(parent, node_size_constraints, ["NODE_LABELS"])
  node_set_string_set_property(parent, node_labels_placement, [
    "INSIDE", "V_TOP", "H_CENTER",
  ])
  let label = create_label(Some(make_node_label_parent(parent)))
  label_set_text(label, "foobar")
  label_set_dimensions(label, 23.0, 22.0)

  { graph, parent, label }
}

///|
#skip
test "Issue682 node label padding respects all directions" {
  reset_graph_model_for_test()
  issue682_test_setup_plain_java_layout()

  let epsilon = 0.00001
  for layout_direction in ["RIGHT", "DOWN", "UP", "LEFT"] {
    let test_graph = issue682_test_graph(layout_direction)
    let layout_engine = new_recursive_graph_layout_engine()
    layout_engine.layout(test_graph.graph, new_null_elk_progress_monitor())

    let label = test_graph.label
    assert_true((label_x(label) - 54.0).abs() <= epsilon)
    assert_true((label_y(label) - 21.0).abs() <= epsilon)
    assert_true(
      (node_width(test_graph.parent) -
      (label_x(label) + label_width(label) + 32.0)).abs() <=
      epsilon,
    )
  }
}
