///|
fn issue682_test_setup_plain_java_layout() -> Unit {
  layout_meta_data_service_reset_for_test()
  plain_java_initialization_reset_for_test()
  plain_java_initialization_initialize_plain_java_layout()
}

///|
struct Issue682TestGraph {
  graph : @graph.ElkNode
  parent : @graph.ElkNode
  label : @graph.ElkLabel
}

///|
fn issue682_test_graph(layout_direction : String) -> Issue682TestGraph {
  let graph = create_graph()
  @graph.node_set_string_property(
    graph, @core.algorithm, "org.eclipse.elk.layered",
  )
  @graph.node_set_string_property(graph, @core.edge_routing, "ORTHOGONAL")
  @graph.node_set_string_property(graph, @core.direction, layout_direction)
  @graph.node_set_layout_option_string_by_id(
    graph, "org.eclipse.elk.nodeLabels.padding", "[top=21,right=32,bottom=43,left=54]",
  )

  let parent = @graph.create_node(Some(graph))
  node_set_string_set_property(parent, @core.node_size_constraints, [
    "NODE_LABELS",
  ])
  node_set_string_set_property(parent, @core.node_labels_placement, [
    "INSIDE", "V_TOP", "H_CENTER",
  ])
  let label = @graph.create_label(Some(make_node_label_parent(parent)))
  @graph.label_set_text(label, "foobar")
  @graph.label_set_dimensions(label, 23.0, 22.0)

  { graph, parent, label }
}

///|
fn issue682_test_assert_close(
  actual : Double,
  expected : Double,
  epsilon : Double,
  context : String,
) -> Unit {
  if (actual - expected).abs() > epsilon {
    let message = "\{context}: expected=\{expected}, actual=\{actual}, epsilon=\{epsilon}"
    println(message)
    abort(message)
  }
}

///|
test "Issue682 node label @core.padding respects all directions" {
  reset_graph_model_for_test()
  issue682_test_setup_plain_java_layout()

  let epsilon = 0.00001
  for layout_direction in ["RIGHT", "DOWN", "UP", "LEFT"] {
    let test_graph = issue682_test_graph(layout_direction)
    let layout_engine = new_recursive_graph_layout_engine()
    layout_engine.layout(
      test_graph.graph,
      @core.new_null_elk_progress_monitor(),
    )

    let label = test_graph.label
    issue682_test_assert_close(
      @graph.label_x(label),
      54.0,
      epsilon,
      "\{layout_direction}.label_x",
    )
    issue682_test_assert_close(
      @graph.label_y(label),
      21.0,
      epsilon,
      "\{layout_direction}.label_y",
    )
    issue682_test_assert_close(
      @graph.node_width(test_graph.parent),
      @graph.label_x(label) + @graph.label_width(label) + 32.0,
      epsilon,
      "\{layout_direction}.parent_width",
    )
  }
}
