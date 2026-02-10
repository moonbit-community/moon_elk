///|
let mrtree_double_eq_epsilon = 0.0001

///|
fn mrtree_assert_close(
  actual : Double,
  expected : Double,
  epsilon : Double,
) -> Unit {
  let diff = if actual >= expected {
    actual - expected
  } else {
    expected - actual
  }
  if diff > epsilon {
    abort("Expected \{expected} but got \{actual} (diff=\{diff})")
  }
}

///|
fn mrtree_test_padding_string(
  left : Double,
  right : Double,
  top : Double,
  bottom : Double,
) -> String {
  "[left=\{left.to_string()}, top=\{top.to_string()}, right=\{right.to_string()}, bottom=\{bottom.to_string()}]"
}

///|
fn mrtree_apply_graph_size_case(
  node_width_value : Double,
  node_height_value : Double,
  padding_left : Double,
  padding_right : Double,
  padding_top : Double,
  padding_bottom : Double,
  node_node_spacing : Double,
) -> Unit {
  reset_graph_model_for_test()
  layout_meta_data_service_reset_for_test()
  layout_meta_data_service_register_default_algorithms()

  let graph = create_graph()
  node_set_string_property(graph, algorithm, "org.eclipse.elk.mrtree")
  node_set_string_property(
    graph,
    padding,
    mrtree_test_padding_string(
      padding_left, padding_right, padding_top, padding_bottom,
    ),
  )
  node_set_double_property(graph, spacing_node_node, node_node_spacing)

  let n1 = create_node(Some(graph))
  node_set_dimensions(n1, node_width_value, node_height_value)
  let n2 = create_node(Some(graph))
  node_set_dimensions(n2, node_width_value, node_height_value)
  let n3 = create_node(Some(graph))
  node_set_dimensions(n3, node_width_value, node_height_value)
  ignore(create_simple_edge(n1, n2))
  ignore(create_simple_edge(n1, n3))

  let engine = new_recursive_graph_layout_engine()
  engine.layout(graph, new_basic_progress_monitor())

  mrtree_assert_close(
    node_width(graph),
    padding_left +
    node_width_value +
    node_node_spacing +
    node_width_value +
    padding_right,
    mrtree_double_eq_epsilon,
  )
  mrtree_assert_close(
    node_height(graph),
    padding_top +
    node_height_value +
    node_node_spacing +
    node_height_value +
    padding_bottom,
    mrtree_double_eq_epsilon,
  )
}

///|
fn mrtree_apply_components_graph_size_case(
  node_width_value : Double,
  node_height_value : Double,
) -> Unit {
  reset_graph_model_for_test()
  layout_meta_data_service_reset_for_test()
  layout_meta_data_service_register_default_algorithms()

  let graph = create_graph()
  node_set_string_property(graph, algorithm, "org.eclipse.elk.mrtree")
  node_set_string_property(
    graph,
    padding,
    mrtree_test_padding_string(0.0, 0.0, 0.0, 0.0),
  )
  node_set_double_property(graph, spacing_node_node, 0.0)
  node_set_double_property(graph, aspect_ratio, 1000.0)

  let n1 = create_node(Some(graph))
  node_set_dimensions(n1, node_width_value, node_height_value)
  let n2 = create_node(Some(graph))
  node_set_dimensions(n2, node_width_value, node_height_value)

  let engine = new_recursive_graph_layout_engine()
  engine.layout(graph, new_basic_progress_monitor())

  mrtree_assert_close(
    node_width(graph),
    node_width_value + node_width_value,
    mrtree_double_eq_epsilon,
  )
  mrtree_assert_close(
    node_height(graph),
    node_height_value,
    mrtree_double_eq_epsilon,
  )
}

///|
test "MrTreeGraphSizeTest graph size calculation" {
  mrtree_apply_graph_size_case(20.0, 20.0, 10.0, 10.0, 10.0, 10.0, 10.0)
  mrtree_apply_graph_size_case(15.0, 30.0, 7.0, 9.0, 11.0, 13.0, 15.0)
  mrtree_apply_graph_size_case(25.0, 15.0, 0.0, 0.0, 0.0, 0.0, 20.0)
}

///|
test "MrTreeGraphSizeTest components graph size calculation" {
  mrtree_apply_components_graph_size_case(20.0, 20.0)
  mrtree_apply_components_graph_size_case(15.0, 30.0)
  mrtree_apply_components_graph_size_case(25.0, 15.0)
}
