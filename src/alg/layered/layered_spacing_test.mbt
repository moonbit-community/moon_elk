///|
let layered_spacing_test_double_eq_epsilon = 0.0001

///|
fn layered_spacing_options_to_test() -> Array[@graph.IProperty[Double]] {
  [
    @core.spacing_component_component, @core.spacing_edge_edge, @core.spacing_edge_label,
    @core.spacing_edge_node, @core.spacing_label_label, @core.spacing_label_node,
    @core.spacing_label_port_horizontal, @core.spacing_label_port_vertical, @core.spacing_node_self_loop,
    @core.spacing_port_port, layered_options_spacing_edge_edge_between_layers, layered_options_spacing_edge_node_between_layers,
    layered_options_spacing_node_node_between_layers,
  ]
}

///|
fn layered_spacing_test_new_node(layer : Layer, node_type : NodeType) -> LNode {
  let node = new_l_node()
  node.set_type(node_type)
  node.set_layer(Some(layer))
  node
}

///|
fn layered_spacing_test_pair(
  first_type : NodeType,
  second_type : NodeType,
) -> (LGraph, LNode, LNode) {
  let graph = new_l_graph()
  let left_layer = new_layer(graph)
  let right_layer = new_layer(graph)
  graph.get_layers().push(left_layer)
  graph.get_layers().push(right_layer)
  let first = layered_spacing_test_new_node(left_layer, first_type)
  let second = layered_spacing_test_new_node(right_layer, second_type)
  (graph, first, second)
}

///|
test "LayeredSpacingsBuilder default factors use layered defaults" {
  let builder = layered_spacings_with_base_value(33.0)
  for option in layered_spacing_options_to_test() {
    let expected = option.get_default() /
      layered_spacings_base_spacing_option.get_default()
    assert_double_eq(
      builder.factor_for(option),
      expected,
      layered_spacing_test_double_eq_epsilon,
    )
  }
}

///|
test "LayeredSpacingsBuilder apply respects overwrite flag" {
  let graph = new_l_graph()
  graph.set_property_double(@core.spacing_edge_node, 99.0)

  layered_spacings_with_base_value(35.0)
  .with_value(@core.spacing_edge_node, 24.0)
  .with_overwrite(false)
  .apply(graph)

  assert_double_eq(
    graph.get_property_double(@core.spacing_edge_node),
    99.0,
    layered_spacing_test_double_eq_epsilon,
  )
  assert_double_eq(
    graph.get_property_double(@core.spacing_node_node),
    35.0,
    layered_spacing_test_double_eq_epsilon,
  )

  layered_spacings_with_base_value(35.0)
  .with_value(@core.spacing_edge_node, 24.0)
  .with_overwrite(true)
  .apply(graph)

  assert_double_eq(
    graph.get_property_double(@core.spacing_edge_node),
    24.0,
    layered_spacing_test_double_eq_epsilon,
  )
}

///|
test "Spacings uses between-layer option mapping for normal-long-edge" {
  let types = node_type_values()
  let (graph, normal, long_edge) = layered_spacing_test_pair(types[0], types[1])
  graph.set_property_double(
    layered_options_spacing_edge_node_between_layers, 31.0,
  )
  let spacings = new_layered_spacings(graph)
  assert_double_eq(
    spacings.get_horizontal_spacing(normal, long_edge),
    31.0,
    layered_spacing_test_double_eq_epsilon,
  )
}

///|
test "Spacings uses max of node-specific and graph spacing values" {
  let types = node_type_values()
  let (graph, normal, long_edge) = layered_spacing_test_pair(types[0], types[1])
  graph.set_property_double(@core.spacing_edge_node, 31.0)
  normal.set_property_double(@core.spacing_edge_node, 5.0)
  long_edge.set_property_double(@core.spacing_edge_node, 42.0)
  let spacings = new_layered_spacings(graph)
  assert_double_eq(
    spacings.get_vertical_spacing(normal, long_edge),
    42.0,
    layered_spacing_test_double_eq_epsilon,
  )
}

///|
test "Spacings maps external-port label spacing horizontal and vertical options" {
  let types = node_type_values()
  let (graph, external_port, label_node) = layered_spacing_test_pair(
    types[2],
    types[4],
  )
  graph.set_property_double(@core.spacing_label_port_horizontal, 7.0)
  graph.set_property_double(@core.spacing_label_port_vertical, 13.0)

  let spacings = new_layered_spacings(graph)
  assert_double_eq(
    spacings.get_horizontal_spacing(external_port, label_node),
    7.0,
    layered_spacing_test_double_eq_epsilon,
  )
  assert_double_eq(
    spacings.get_vertical_spacing(external_port, label_node),
    13.0,
    layered_spacing_test_double_eq_epsilon,
  )
}

///|
test "panic Spacings unspecified node-type combination panics" {
  let types = node_type_values()
  let graph = new_l_graph()
  let spacings = new_layered_spacings(graph)
  ignore(spacings.get_horizontal_spacing_for_node_type(types[6], types[6]))
}
