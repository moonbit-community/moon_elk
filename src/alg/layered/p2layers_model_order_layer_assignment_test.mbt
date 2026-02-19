///|
fn p2_model_order_layer_assignment_test_setup_plain_java_layout() -> Unit {
  layout_meta_data_service_reset_for_test()
  plain_java_initialization_reset_for_test()
  plain_java_initialization_initialize_plain_java_layout()
}

///|
fn p2_model_order_layer_assignment_test_layout(graph : @graph.ElkNode) -> Unit {
  let resolver = new_layout_algorithm_resolver()
  apply_visitors(graph, [resolver.to_visitor()])
  let layout_engine = new_recursive_graph_layout_engine()
  layout_engine.layout(graph, @core.new_null_elk_progress_monitor())
}

///|
fn p2_model_order_layer_assignment_test_add_node_label(
  node : @graph.ElkNode,
  text : String,
) -> Unit {
  let label = @graph.create_label(Some(make_node_label_parent(node)))
  @graph.label_set_text(label, text)
}

///|
fn p2_model_order_layer_assignment_test_add_node(
  parent : @graph.ElkNode,
  text : String,
) -> @graph.ElkNode {
  let node = @graph.create_node(Some(parent))
  @graph.node_set_dimensions(node, 30.0, 30.0)
  p2_model_order_layer_assignment_test_add_node_label(node, text)
  node
}

///|
fn p2_model_order_layer_assignment_test_connect(
  source : @graph.ElkNode,
  target : @graph.ElkNode,
) -> Unit {
  let edge = create_edge(None)
  edge_add_source(edge, make_node_shape(source))
  edge_add_target(edge, make_node_shape(target))
  update_containment(Some(edge))
}

///|
fn p2_model_order_layer_assignment_test_configure(
  parent : @graph.ElkNode,
  layering_strategy : String,
  node_promotion_strategy : String,
) -> Unit {
  @graph.node_set_string_property(
    parent, @core.algorithm, "org.eclipse.elk.layered",
  )
  @graph.node_set_string_property(parent, @core.direction, "RIGHT")
  @graph.node_set_layout_option_string_by_id(
    parent, "org.eclipse.elk.algorithm", "org.eclipse.elk.layered",
  )
  @graph.node_set_layout_option_string_by_id(
    parent, "org.eclipse.elk.direction", "RIGHT",
  )
  @graph.node_set_string_property(
    parent, layered_options_consider_model_order_strategy, "PREFER_EDGES",
  )
  @graph.node_set_layout_option_string_by_id(
    parent, "org.eclipse.elk.layered.layering.strategy", layering_strategy,
  )
  @graph.node_set_layout_option_string_by_id(
    parent, "org.eclipse.elk.layered.nodePromotion.strategy", node_promotion_strategy,
  )
  @graph.node_set_string_property(
    parent,
    @core.padding,
    new_elk_padding_any(0.0).to_string(),
  )
  @graph.node_set_layout_option_string_by_id(
    parent, "org.eclipse.elk.padding", "[left=0,top=0,right=0,bottom=0]",
  )
  @graph.node_set_double_property(parent, @core.spacing_node_node, 10.0)
  @graph.node_set_double_property(
    parent, layered_options_spacing_node_node_between_layers, 20.0,
  )
}

///|
fn p2_model_order_layer_assignment_test_assert_close(
  label : String,
  actual : Double,
  expected : Double,
) -> Unit {
  let epsilon = 0.1
  if (actual - expected).abs() > epsilon {
    abort("\{label}: expected=\{expected}, actual=\{actual}")
  }
}

///|
test "ModelOrderLayerAssignment forward promotion disregards edge length" {
  reset_graph_model_for_test()
  p2_model_order_layer_assignment_test_setup_plain_java_layout()

  let parent = create_graph()
  let n1 = p2_model_order_layer_assignment_test_add_node(parent, "n1")
  let n2 = p2_model_order_layer_assignment_test_add_node(parent, "n2")
  let n3 = p2_model_order_layer_assignment_test_add_node(parent, "n3")
  let n4 = p2_model_order_layer_assignment_test_add_node(parent, "n4")
  let n5 = p2_model_order_layer_assignment_test_add_node(parent, "n5")

  p2_model_order_layer_assignment_test_configure(
    parent, "LONGEST_PATH_SOURCE", "MODEL_ORDER_LEFT_TO_RIGHT",
  )

  p2_model_order_layer_assignment_test_connect(n1, n2)
  p2_model_order_layer_assignment_test_connect(n1, n4)
  p2_model_order_layer_assignment_test_connect(n1, n4)
  p2_model_order_layer_assignment_test_connect(n2, n3)
  p2_model_order_layer_assignment_test_connect(n3, n5)
  p2_model_order_layer_assignment_test_connect(n4, n5)

  p2_model_order_layer_assignment_test_layout(parent)

  p2_model_order_layer_assignment_test_assert_close(
    "n1.x",
    @graph.node_x(n1),
    0.0,
  )
  p2_model_order_layer_assignment_test_assert_close(
    "n1.y",
    @graph.node_y(n1),
    7.5,
  )
  p2_model_order_layer_assignment_test_assert_close(
    "n2.x",
    @graph.node_x(n2),
    60.0,
  )
  p2_model_order_layer_assignment_test_assert_close(
    "n2.y",
    @graph.node_y(n2),
    0.0,
  )
  p2_model_order_layer_assignment_test_assert_close(
    "n3.x",
    @graph.node_x(n3),
    110.0,
  )
  p2_model_order_layer_assignment_test_assert_close(
    "n3.y",
    @graph.node_y(n3),
    0.0,
  )
  p2_model_order_layer_assignment_test_assert_close(
    "n4.x",
    @graph.node_x(n4),
    110.0,
  )
  p2_model_order_layer_assignment_test_assert_close(
    "n4.y",
    @graph.node_y(n4),
    40.0,
  )
  p2_model_order_layer_assignment_test_assert_close(
    "n5.x",
    @graph.node_x(n5),
    160.0,
  )
  p2_model_order_layer_assignment_test_assert_close(
    "n5.y",
    @graph.node_y(n5),
    5.0,
  )
}

///|
test "ModelOrderLayerAssignment backward promotion disregards edge length" {
  reset_graph_model_for_test()
  p2_model_order_layer_assignment_test_setup_plain_java_layout()

  let parent = create_graph()
  let n1 = p2_model_order_layer_assignment_test_add_node(parent, "n1")
  let n2 = p2_model_order_layer_assignment_test_add_node(parent, "n2")
  let n3 = p2_model_order_layer_assignment_test_add_node(parent, "n3")
  let n4 = p2_model_order_layer_assignment_test_add_node(parent, "n4")
  let n5 = p2_model_order_layer_assignment_test_add_node(parent, "n5")

  p2_model_order_layer_assignment_test_configure(
    parent, "LONGEST_PATH", "MODEL_ORDER_RIGHT_TO_LEFT",
  )

  p2_model_order_layer_assignment_test_connect(n1, n2)
  p2_model_order_layer_assignment_test_connect(n1, n3)
  p2_model_order_layer_assignment_test_connect(n2, n5)
  p2_model_order_layer_assignment_test_connect(n2, n5)
  p2_model_order_layer_assignment_test_connect(n3, n4)
  p2_model_order_layer_assignment_test_connect(n4, n5)

  p2_model_order_layer_assignment_test_layout(parent)

  p2_model_order_layer_assignment_test_assert_close(
    "n1.x",
    @graph.node_x(n1),
    0.0,
  )
  p2_model_order_layer_assignment_test_assert_close(
    "n1.y",
    @graph.node_y(n1),
    5.0,
  )
  p2_model_order_layer_assignment_test_assert_close(
    "n2.x",
    @graph.node_x(n2),
    50.0,
  )
  p2_model_order_layer_assignment_test_assert_close(
    "n2.y",
    @graph.node_y(n2),
    0.0,
  )
  p2_model_order_layer_assignment_test_assert_close(
    "n3.x",
    @graph.node_x(n3),
    50.0,
  )
  p2_model_order_layer_assignment_test_assert_close(
    "n3.y",
    @graph.node_y(n3),
    40.0,
  )
  p2_model_order_layer_assignment_test_assert_close(
    "n4.x",
    @graph.node_x(n4),
    100.0,
  )
  p2_model_order_layer_assignment_test_assert_close(
    "n4.y",
    @graph.node_y(n4),
    40.0,
  )
  p2_model_order_layer_assignment_test_assert_close(
    "n5.x",
    @graph.node_x(n5),
    150.0,
  )
  p2_model_order_layer_assignment_test_assert_close(
    "n5.y",
    @graph.node_y(n5),
    6.0,
  )
}

///|
test "ModelOrderLayerAssignment forward promotion more nodes" {
  reset_graph_model_for_test()
  p2_model_order_layer_assignment_test_setup_plain_java_layout()

  let parent = create_graph()
  let n1 = p2_model_order_layer_assignment_test_add_node(parent, "n1")
  let n2 = p2_model_order_layer_assignment_test_add_node(parent, "n2")
  let n3 = p2_model_order_layer_assignment_test_add_node(parent, "n3")
  let n4 = p2_model_order_layer_assignment_test_add_node(parent, "n4")
  let n5 = p2_model_order_layer_assignment_test_add_node(parent, "n5")
  let n6 = p2_model_order_layer_assignment_test_add_node(parent, "n6")

  p2_model_order_layer_assignment_test_configure(
    parent, "LONGEST_PATH_SOURCE", "MODEL_ORDER_LEFT_TO_RIGHT",
  )

  p2_model_order_layer_assignment_test_connect(n1, n2)
  p2_model_order_layer_assignment_test_connect(n1, n4)
  p2_model_order_layer_assignment_test_connect(n1, n4)
  p2_model_order_layer_assignment_test_connect(n1, n5)
  p2_model_order_layer_assignment_test_connect(n2, n3)
  p2_model_order_layer_assignment_test_connect(n3, n6)
  p2_model_order_layer_assignment_test_connect(n4, n6)
  p2_model_order_layer_assignment_test_connect(n5, n6)

  p2_model_order_layer_assignment_test_layout(parent)

  p2_model_order_layer_assignment_test_assert_close(
    "n1.x",
    @graph.node_x(n1),
    0.0,
  )
  p2_model_order_layer_assignment_test_assert_close(
    "n1.y",
    @graph.node_y(n1),
    9.0,
  )
  p2_model_order_layer_assignment_test_assert_close(
    "n2.x",
    @graph.node_x(n2),
    70.0,
  )
  p2_model_order_layer_assignment_test_assert_close(
    "n2.y",
    @graph.node_y(n2),
    0.0,
  )
  p2_model_order_layer_assignment_test_assert_close(
    "n3.x",
    @graph.node_x(n3),
    120.0,
  )
  p2_model_order_layer_assignment_test_assert_close(
    "n3.y",
    @graph.node_y(n3),
    0.0,
  )
  p2_model_order_layer_assignment_test_assert_close(
    "n4.x",
    @graph.node_x(n4),
    120.0,
  )
  p2_model_order_layer_assignment_test_assert_close(
    "n4.y",
    @graph.node_y(n4),
    40.0,
  )
  p2_model_order_layer_assignment_test_assert_close(
    "n5.x",
    @graph.node_x(n5),
    120.0,
  )
  p2_model_order_layer_assignment_test_assert_close(
    "n5.y",
    @graph.node_y(n5),
    80.0,
  )
  p2_model_order_layer_assignment_test_assert_close(
    "n6.x",
    @graph.node_x(n6),
    170.0,
  )
  p2_model_order_layer_assignment_test_assert_close(
    "n6.y",
    @graph.node_y(n6),
    40.0,
  )
}

///|
test "ModelOrderLayerAssignment backward promotion more nodes" {
  reset_graph_model_for_test()
  p2_model_order_layer_assignment_test_setup_plain_java_layout()

  let parent = create_graph()
  let n1 = p2_model_order_layer_assignment_test_add_node(parent, "n1")
  let n2 = p2_model_order_layer_assignment_test_add_node(parent, "n2")
  let n3 = p2_model_order_layer_assignment_test_add_node(parent, "n3")
  let n4 = p2_model_order_layer_assignment_test_add_node(parent, "n4")
  let n5 = p2_model_order_layer_assignment_test_add_node(parent, "n5")
  let n6 = p2_model_order_layer_assignment_test_add_node(parent, "n6")

  p2_model_order_layer_assignment_test_configure(
    parent, "LONGEST_PATH", "MODEL_ORDER_RIGHT_TO_LEFT",
  )

  p2_model_order_layer_assignment_test_connect(n1, n2)
  p2_model_order_layer_assignment_test_connect(n1, n3)
  p2_model_order_layer_assignment_test_connect(n1, n4)
  p2_model_order_layer_assignment_test_connect(n2, n6)
  p2_model_order_layer_assignment_test_connect(n2, n6)
  p2_model_order_layer_assignment_test_connect(n3, n6)
  p2_model_order_layer_assignment_test_connect(n4, n5)
  p2_model_order_layer_assignment_test_connect(n5, n6)

  p2_model_order_layer_assignment_test_layout(parent)

  p2_model_order_layer_assignment_test_assert_close(
    "n1.x",
    @graph.node_x(n1),
    0.0,
  )
  p2_model_order_layer_assignment_test_assert_close(
    "n1.y",
    @graph.node_y(n1),
    7.5,
  )
  p2_model_order_layer_assignment_test_assert_close(
    "n2.x",
    @graph.node_x(n2),
    60.0,
  )
  p2_model_order_layer_assignment_test_assert_close(
    "n2.y",
    @graph.node_y(n2),
    0.0,
  )
  p2_model_order_layer_assignment_test_assert_close(
    "n3.x",
    @graph.node_x(n3),
    60.0,
  )
  p2_model_order_layer_assignment_test_assert_close(
    "n3.y",
    @graph.node_y(n3),
    40.0,
  )
  p2_model_order_layer_assignment_test_assert_close(
    "n4.x",
    @graph.node_x(n4),
    60.0,
  )
  p2_model_order_layer_assignment_test_assert_close(
    "n4.y",
    @graph.node_y(n4),
    80.0,
  )
  p2_model_order_layer_assignment_test_assert_close(
    "n5.x",
    @graph.node_x(n5),
    110.0,
  )
  p2_model_order_layer_assignment_test_assert_close(
    "n5.y",
    @graph.node_y(n5),
    80.0,
  )
  p2_model_order_layer_assignment_test_assert_close(
    "n6.x",
    @graph.node_x(n6),
    170.0,
  )
  p2_model_order_layer_assignment_test_assert_close(
    "n6.y",
    @graph.node_y(n6),
    9.0,
  )
}

///|
test "ModelOrderLayerAssignment forward promotion no end node" {
  reset_graph_model_for_test()
  p2_model_order_layer_assignment_test_setup_plain_java_layout()

  let parent = create_graph()
  let n1 = p2_model_order_layer_assignment_test_add_node(parent, "n1")
  let n2 = p2_model_order_layer_assignment_test_add_node(parent, "n2")
  let n3 = p2_model_order_layer_assignment_test_add_node(parent, "n3")
  let n4 = p2_model_order_layer_assignment_test_add_node(parent, "n4")

  p2_model_order_layer_assignment_test_configure(
    parent, "LONGEST_PATH_SOURCE", "MODEL_ORDER_LEFT_TO_RIGHT",
  )

  p2_model_order_layer_assignment_test_connect(n1, n2)
  p2_model_order_layer_assignment_test_connect(n1, n4)
  p2_model_order_layer_assignment_test_connect(n1, n4)
  p2_model_order_layer_assignment_test_connect(n2, n3)

  p2_model_order_layer_assignment_test_layout(parent)

  p2_model_order_layer_assignment_test_assert_close(
    "n1.x",
    @graph.node_x(n1),
    0.0,
  )
  p2_model_order_layer_assignment_test_assert_close(
    "n1.y",
    @graph.node_y(n1),
    7.5,
  )
  p2_model_order_layer_assignment_test_assert_close(
    "n2.x",
    @graph.node_x(n2),
    60.0,
  )
  p2_model_order_layer_assignment_test_assert_close(
    "n2.y",
    @graph.node_y(n2),
    0.0,
  )
  p2_model_order_layer_assignment_test_assert_close(
    "n3.x",
    @graph.node_x(n3),
    110.0,
  )
  p2_model_order_layer_assignment_test_assert_close(
    "n3.y",
    @graph.node_y(n3),
    0.0,
  )
  p2_model_order_layer_assignment_test_assert_close(
    "n4.x",
    @graph.node_x(n4),
    110.0,
  )
  p2_model_order_layer_assignment_test_assert_close(
    "n4.y",
    @graph.node_y(n4),
    40.0,
  )
}

///|
test "ModelOrderLayerAssignment backward promotion no end node" {
  reset_graph_model_for_test()
  p2_model_order_layer_assignment_test_setup_plain_java_layout()

  let parent = create_graph()
  let n1 = p2_model_order_layer_assignment_test_add_node(parent, "n1")
  let n2 = p2_model_order_layer_assignment_test_add_node(parent, "n2")
  let n3 = p2_model_order_layer_assignment_test_add_node(parent, "n3")
  let n4 = p2_model_order_layer_assignment_test_add_node(parent, "n4")

  p2_model_order_layer_assignment_test_configure(
    parent, "LONGEST_PATH", "MODEL_ORDER_RIGHT_TO_LEFT",
  )

  p2_model_order_layer_assignment_test_connect(n1, n4)
  p2_model_order_layer_assignment_test_connect(n1, n4)
  p2_model_order_layer_assignment_test_connect(n2, n3)
  p2_model_order_layer_assignment_test_connect(n3, n4)

  p2_model_order_layer_assignment_test_layout(parent)

  p2_model_order_layer_assignment_test_assert_close(
    "n1.x",
    @graph.node_x(n1),
    0.0,
  )
  p2_model_order_layer_assignment_test_assert_close(
    "n1.y",
    @graph.node_y(n1),
    0.0,
  )
  p2_model_order_layer_assignment_test_assert_close(
    "n2.x",
    @graph.node_x(n2),
    0.0,
  )
  p2_model_order_layer_assignment_test_assert_close(
    "n2.y",
    @graph.node_y(n2),
    40.0,
  )
  p2_model_order_layer_assignment_test_assert_close(
    "n3.x",
    @graph.node_x(n3),
    50.0,
  )
  p2_model_order_layer_assignment_test_assert_close(
    "n3.y",
    @graph.node_y(n3),
    40.0,
  )
  p2_model_order_layer_assignment_test_assert_close(
    "n4.x",
    @graph.node_x(n4),
    100.0,
  )
  p2_model_order_layer_assignment_test_assert_close(
    "n4.y",
    @graph.node_y(n4),
    6.0,
  )
}

///|
test "ModelOrderLayerAssignment backward promotion no end node 2" {
  reset_graph_model_for_test()
  p2_model_order_layer_assignment_test_setup_plain_java_layout()

  let parent = create_graph()
  let n1 = p2_model_order_layer_assignment_test_add_node(parent, "n1")
  let n2 = p2_model_order_layer_assignment_test_add_node(parent, "n2")
  let n3 = p2_model_order_layer_assignment_test_add_node(parent, "n3")
  let n4 = p2_model_order_layer_assignment_test_add_node(parent, "n4")

  p2_model_order_layer_assignment_test_configure(
    parent, "LONGEST_PATH", "MODEL_ORDER_RIGHT_TO_LEFT",
  )

  p2_model_order_layer_assignment_test_connect(n1, n2)
  p2_model_order_layer_assignment_test_connect(n1, n3)
  p2_model_order_layer_assignment_test_connect(n3, n4)

  p2_model_order_layer_assignment_test_layout(parent)

  p2_model_order_layer_assignment_test_assert_close(
    "n1.x",
    @graph.node_x(n1),
    0.0,
  )
  p2_model_order_layer_assignment_test_assert_close(
    "n1.y",
    @graph.node_y(n1),
    5.0,
  )
  p2_model_order_layer_assignment_test_assert_close(
    "n2.x",
    @graph.node_x(n2),
    50.0,
  )
  p2_model_order_layer_assignment_test_assert_close(
    "n2.y",
    @graph.node_y(n2),
    0.0,
  )
  p2_model_order_layer_assignment_test_assert_close(
    "n3.x",
    @graph.node_x(n3),
    50.0,
  )
  p2_model_order_layer_assignment_test_assert_close(
    "n3.y",
    @graph.node_y(n3),
    40.0,
  )
  p2_model_order_layer_assignment_test_assert_close(
    "n4.x",
    @graph.node_x(n4),
    100.0,
  )
  p2_model_order_layer_assignment_test_assert_close(
    "n4.y",
    @graph.node_y(n4),
    40.0,
  )
}
