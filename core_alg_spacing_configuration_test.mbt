///|
let spacing_test_double_eq_epsilon = 0.0001

///|
fn create_spacing_test_graph() -> ElkNode {
  let graph = create_graph()
  let node1 = create_node(Some(graph))
  node_set_dimensions(node1, 30.0, 30.0)
  let node2 = create_node(Some(graph))
  node_set_dimensions(node2, 30.0, 30.0)
  ignore(create_simple_edge(node1, node2))
  graph
}

///|
fn create_and_configure_spacing_test_graph(
  configurator : IGraphElementVisitor,
) -> ElkNode {
  let graph = create_spacing_test_graph()
  apply_visitor(graph, configurator)
  graph
}

///|
fn check_spacing_option_value(
  graph : ElkNode,
  option : IProperty[Double],
  value : Double,
) -> Unit raise {
  for element in properties_skipping_nodes(graph, include_root=true) {
    assert_double_eq(
      node_get_double_property(element, option),
      value,
      spacing_test_double_eq_epsilon,
    )
  }
}

///|
fn spacing_options_to_test() -> Array[IProperty[Double]] {
  [
    spacing_component_component, spacing_edge_edge, spacing_edge_label, spacing_edge_node,
    spacing_label_label, spacing_label_node, spacing_label_port_horizontal, spacing_label_port_vertical,
    spacing_node_self_loop, spacing_port_port,
  ]
}

///|
test "SpacingConfiguration testCreateVisitor" {
  reset_graph_model_for_test()
  let node = create_node(None)
  let visitor = elk_spacings_with_base_value(3.0).to_visitor()
  visitor.visit(node)
  assert_double_eq(
    node_get_double_property(node, spacing_node_node),
    3.0,
    spacing_test_double_eq_epsilon,
  )
}

///|
test "SpacingConfiguration testApplyTo" {
  reset_graph_model_for_test()
  let node = create_node(None)
  elk_spacings_with_base_value(3.0).apply(node)
  assert_double_eq(
    node_get_double_property(node, spacing_node_node),
    3.0,
    spacing_test_double_eq_epsilon,
  )
}

///|
test "panic SpacingConfiguration testSpacingWithNegativeFactor" {
  reset_graph_model_for_test()
  ignore(
    create_and_configure_spacing_test_graph(
      elk_spacings_with_base_value(33.0)
      .with_factor(spacing_edge_edge, -0.000000001)
      .to_visitor(),
    ),
  )
}

///|
test "panic SpacingConfiguration testSpacingWithNegativeValue" {
  reset_graph_model_for_test()
  ignore(
    create_and_configure_spacing_test_graph(
      elk_spacings_with_base_value(33.0)
      .with_value(spacing_edge_edge, -0.000000001)
      .to_visitor(),
    ),
  )
}

///|
test "SpacingConfiguration testDefaultFactors" {
  let builder = elk_spacings_with_base_value(33.0)
  for option in spacing_options_to_test() {
    let value = builder.factor_for(option)
    let expected = option.get_default() / spacing_node_node.get_default()
    assert_double_eq(value, expected, spacing_test_double_eq_epsilon)
  }
}

///|
test "SpacingConfiguration testSpacingWithFactor" {
  reset_graph_model_for_test()
  for option in spacing_options_to_test() {
    let graph = create_and_configure_spacing_test_graph(
      elk_spacings_with_base_value(33.0).with_factor(option, 2.0).to_visitor(),
    )
    check_spacing_option_value(graph, option, 66.0)
  }
}

///|
test "SpacingConfiguration testSpacingWithValue" {
  reset_graph_model_for_test()
  for option in spacing_options_to_test() {
    let graph = create_and_configure_spacing_test_graph(
      elk_spacings_with_base_value(33.0).with_value(option, 24.0).to_visitor(),
    )
    check_spacing_option_value(graph, option, 24.0)
  }
}

///|
test "SpacingConfiguration testOverwriteIfRequested" {
  reset_graph_model_for_test()
  for option in spacing_options_to_test() {
    let graph = create_spacing_test_graph()
    let first_child = node_children(graph)[0]
    let second_child = node_children(graph)[1]
    node_set_double_property(first_child, option, 22.0)
    apply_visitor(
      graph,
      elk_spacings_with_base_value(1.0)
      .with_value(option, 3.0)
      .with_overwrite(true)
      .to_visitor(),
    )
    assert_double_eq(
      node_get_double_property(first_child, option),
      3.0,
      spacing_test_double_eq_epsilon,
    )
    assert_double_eq(
      node_get_double_property(second_child, option),
      3.0,
      spacing_test_double_eq_epsilon,
    )
  }
}

///|
test "SpacingConfiguration testDontOverwriteIfNotRequested" {
  reset_graph_model_for_test()
  for option in spacing_options_to_test() {
    let graph = create_spacing_test_graph()
    let first_child = node_children(graph)[0]
    let second_child = node_children(graph)[1]
    node_set_double_property(first_child, option, 22.0)
    apply_visitor(
      graph,
      elk_spacings_with_base_value(1.0)
      .with_value(option, 3.0)
      .with_overwrite(false)
      .to_visitor(),
    )
    assert_double_eq(
      node_get_double_property(first_child, option),
      22.0,
      spacing_test_double_eq_epsilon,
    )
    assert_double_eq(
      node_get_double_property(second_child, option),
      3.0,
      spacing_test_double_eq_epsilon,
    )
  }
}

///|
test "panic SpacingConfiguration testSpacingWithFactorInvalidBaseOption" {
  ignore(
    create_and_configure_spacing_test_graph(
      elk_spacings_with_base_value(33.0)
      .with_factor(spacing_node_node, 2.0)
      .to_visitor(),
    ),
  )
}

///|
test "panic SpacingConfiguration testSpacingWithFactorInvalidAspectRatio" {
  ignore(
    create_and_configure_spacing_test_graph(
      elk_spacings_with_base_value(33.0)
      .with_factor(aspect_ratio, 2.0)
      .to_visitor(),
    ),
  )
}

///|
test "panic SpacingConfiguration testSpacingWithValueInvalidBaseOption" {
  ignore(
    create_and_configure_spacing_test_graph(
      elk_spacings_with_base_value(33.0)
      .with_value(spacing_node_node, 24.0)
      .to_visitor(),
    ),
  )
}

///|
test "panic SpacingConfiguration testSpacingWithValueInvalidAspectRatio" {
  ignore(
    create_and_configure_spacing_test_graph(
      elk_spacings_with_base_value(33.0)
      .with_value(aspect_ratio, 24.0)
      .to_visitor(),
    ),
  )
}
