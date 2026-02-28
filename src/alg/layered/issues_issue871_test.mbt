///|
fn issue871_test_setup_plain_java_layout() -> Unit {
  layout_meta_data_service_reset_for_test()
  plain_java_initialization_reset_for_test()
  plain_java_initialization_initialize_plain_java_layout()
}

///|
fn issue871_connect_nodes(
  source : @graph.ElkNode,
  target : @graph.ElkNode,
) -> @graph.ElkEdge {
  let edge = create_edge(None)
  edge_add_source(edge, make_node_shape(source))
  edge_add_target(edge, make_node_shape(target))
  layered_test_update_containment(Some(edge))
  edge
}

///|
fn issue871_add_node_label(node : @graph.ElkNode, text : String) -> Unit {
  let label = @graph.create_label(Some(make_node_label_parent(node)))
  @graph.label_set_text(label, text)
}

///|
fn issue871_add_edge_label(edge : @graph.ElkEdge, text : String) -> Unit {
  let label = @graph.create_label(Some(make_edge_label_parent(edge)))
  @graph.label_set_text(label, text)
}

///|
fn issue871_configure_parent(
  parent : @graph.ElkNode,
  feedback_edges : Bool,
) -> Unit {
  @graph.node_set_string_property(
    parent, @core.algorithm, "org.eclipse.elk.layered",
  )
  @graph.node_set_string_property(parent, @core.direction, "RIGHT")
  @graph.node_set_layout_option_string_by_id(
    parent, "org.eclipse.elk.layered.cycleBreaking.strategy", "MODEL_ORDER",
  )
  @graph.node_set_string_property(
    parent, layered_options_consider_model_order_strategy, "PREFER_EDGES",
  )
  @graph.node_set_string_property(
    parent, layered_options_crossing_minimization_strategy, "NONE",
  )
  @graph.node_set_string_property(
    parent, layered_options_crossing_minimization_greedy_switch_type, "OFF",
  )
  @graph.node_set_string_property(
    parent,
    @core.padding,
    new_elk_padding_any(0.0).to_string(),
  )
  @graph.node_set_double_property(parent, @core.spacing_node_node, 10.0)
  @graph.node_set_double_property(
    parent, layered_options_spacing_node_node_between_layers, 20.0,
  )
  @graph.node_set_bool_property(
    parent, layered_options_feedback_edges, feedback_edges,
  )
}

///|
fn issue871_assert_close(
  context : String,
  actual : Double,
  expected : Double,
  epsilon : Double,
) -> Unit {
  if (actual - expected).abs() > epsilon {
    let message = "\{context}: expected=\{expected}, actual=\{actual}, epsilon=\{epsilon}"
    println(message)
    abort(message)
  }
}

///|
test "Issue871 feedback edge below keeps aligned node pair" {
  reset_graph_model_for_test()
  issue871_test_setup_plain_java_layout()

  let parent = create_graph()
  let n1 = @graph.create_node(Some(parent))
  let n2 = @graph.create_node(Some(parent))
  let n3 = @graph.create_node(Some(parent))
  let n4 = @graph.create_node(Some(parent))
  @graph.node_set_dimensions(n1, 30.0, 30.0)
  @graph.node_set_dimensions(n2, 30.0, 30.0)
  @graph.node_set_dimensions(n3, 30.0, 30.0)
  @graph.node_set_dimensions(n4, 30.0, 30.0)
  issue871_configure_parent(parent, true)

  ignore(issue871_connect_nodes(n1, n2))
  ignore(issue871_connect_nodes(n1, n3))
  ignore(issue871_connect_nodes(n2, n4))
  ignore(issue871_connect_nodes(n4, n3))
  issue871_add_node_label(n1, "n1")
  issue871_add_node_label(n2, "n2")
  issue871_add_node_label(n3, "n3")
  issue871_add_node_label(n4, "n4")

  let layout_engine = new_recursive_graph_layout_engine()
  layout_engine.layout(parent, new_basic_progress_monitor())

  issue871_assert_close(
    "feedback-below n2.y vs n4.y",
    @graph.node_y(n2),
    @graph.node_y(n4),
    0.1,
  )
}

///|
test "Issue871 basic feedback edge keeps aligned nodes" {
  reset_graph_model_for_test()
  issue871_test_setup_plain_java_layout()

  let parent = create_graph()
  let n1 = @graph.create_node(Some(parent))
  let n2 = @graph.create_node(Some(parent))
  let n3 = @graph.create_node(Some(parent))
  @graph.node_set_dimensions(n1, 30.0, 30.0)
  @graph.node_set_dimensions(n2, 30.0, 30.0)
  @graph.node_set_dimensions(n3, 30.0, 30.0)
  issue871_configure_parent(parent, true)

  ignore(issue871_connect_nodes(n1, n2))
  ignore(issue871_connect_nodes(n2, n3))
  ignore(issue871_connect_nodes(n3, n2))
  issue871_add_node_label(n1, "n1")
  issue871_add_node_label(n2, "n2")
  issue871_add_node_label(n3, "n3")

  let layout_engine = new_recursive_graph_layout_engine()
  layout_engine.layout(parent, new_basic_progress_monitor())

  issue871_assert_close(
    "feedback-basic n2.y vs n3.y",
    @graph.node_y(n2),
    @graph.node_y(n3),
    0.1,
  )
}

///|
test "Issue871 no-feedback case keeps reference coordinates" {
  reset_graph_model_for_test()
  issue871_test_setup_plain_java_layout()

  let parent = create_graph()
  let n1 = @graph.create_node(Some(parent))
  let n2 = @graph.create_node(Some(parent))
  let n3 = @graph.create_node(Some(parent))
  let n4 = @graph.create_node(Some(parent))
  @graph.node_set_dimensions(n1, 30.0, 30.0)
  @graph.node_set_dimensions(n2, 30.0, 30.0)
  @graph.node_set_dimensions(n3, 30.0, 30.0)
  @graph.node_set_dimensions(n4, 30.0, 30.0)
  issue871_configure_parent(parent, false)

  let e1 = issue871_connect_nodes(n1, n2)
  issue871_add_edge_label(e1, "1")
  let e2 = issue871_connect_nodes(n1, n4)
  issue871_add_edge_label(e2, "2")
  ignore(issue871_connect_nodes(n2, n4))
  ignore(issue871_connect_nodes(n3, n2))
  ignore(issue871_connect_nodes(n3, n4))
  issue871_add_node_label(n1, "n1")
  issue871_add_node_label(n2, "n2")
  issue871_add_node_label(n3, "n3")
  issue871_add_node_label(n4, "n4")

  let layout_engine = new_recursive_graph_layout_engine()
  layout_engine.layout(parent, new_basic_progress_monitor())

  issue871_assert_close("no-feedback n1.x", @graph.node_x(n1), 0.0, 0.1)
  issue871_assert_close("no-feedback n1.y", @graph.node_y(n1), 31.0, 0.1)
  issue871_assert_close("no-feedback n2.x", @graph.node_x(n2), 70.0, 0.1)
  issue871_assert_close("no-feedback n2.y", @graph.node_y(n2), 6.0, 0.1)
  issue871_assert_close("no-feedback n3.x", @graph.node_x(n3), 120.0, 0.1)
  issue871_assert_close("no-feedback n3.y", @graph.node_y(n3), 11.0, 0.1)
  issue871_assert_close("no-feedback n4.x", @graph.node_x(n4), 170.0, 0.1)
  issue871_assert_close("no-feedback n4.y", @graph.node_y(n4), 11.0, 0.1)
}
