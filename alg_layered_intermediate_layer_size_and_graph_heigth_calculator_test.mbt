///|
fn layer_size_and_graph_height_test_node_type(name : String) -> NodeType {
  for node_type in node_type_values() {
    match node_type {
      NodeType::Normal => if name == "NORMAL" { return node_type }
      NodeType::LongEdge => if name == "LONG_EDGE" { return node_type }
      NodeType::ExternalPort => if name == "EXTERNAL_PORT" { return node_type }
      NodeType::NorthSouthPort =>
        if name == "NORTH_SOUTH_PORT" {
          return node_type
        }
      NodeType::LabelNode => if name == "LABEL_NODE" { return node_type }
      NodeType::BreakingPoint =>
        if name == "BREAKING_POINT" {
          return node_type
        }
      NodeType::Placeholder => if name == "PLACEHOLDER" { return node_type }
      NodeType::NonshiftingPlaceholder =>
        if name == "NONSHIFTING_PLACEHOLDER" {
          return node_type
        }
    }
  }
  abort("unknown node type")
}

///|
fn layer_size_and_graph_height_test_new_graph_with_layer() -> (LGraph, Layer) {
  let graph = new_l_graph()
  let layer = new_layer(graph)
  graph.get_layers().push(layer)
  (graph, layer)
}

///|
test "layer size and graph height calculator reports expected task name" {
  let processor = new_layer_size_and_graph_height_calculator_layout_processor()
  let monitor = new_elk_progress_monitor()
  processor.process(new_l_graph(), Some(monitor))
  inspect(monitor.get_task_name(), content="Layer size calculation")
}

///|
test "layer size and graph height calculator computes layer width height and graph offset" {
  let (graph, layer) = layer_size_and_graph_height_test_new_graph_with_layer()

  let first = new_l_node(graph=Some(graph))
  first.set_layer(Some(layer))
  ignore(first.get_position().set_xy(0.0, 10.0))
  ignore(first.get_size().set_xy(30.0, 20.0))
  first.get_margin().set_values(2.0, 3.0, 4.0, 5.0)

  let second = new_l_node(graph=Some(graph))
  second.set_layer(Some(layer))
  ignore(second.get_position().set_xy(0.0, 50.0))
  ignore(second.get_size().set_xy(10.0, 15.0))
  second.get_margin().set_values(1.0, 1.0, 2.0, 1.0)

  let processor = new_layer_size_and_graph_height_calculator_layout_processor()
  processor.process(graph, None)

  assert_eq(layer.get_size().x, 38.0)
  assert_eq(layer.get_size().y, 59.0)
  assert_eq(graph.get_size().y, 59.0)
  assert_eq(graph.get_offset().y, -8.0)
}

///|
test "layer size and graph height calculator includes additional spacing for external ports" {
  let (graph, layer) = layer_size_and_graph_height_test_new_graph_with_layer()
  graph.set_property_elk_margin(
    layered_options_spacing_ports_surrounding,
    new_elk_margin_values(4.0, 0.0, 6.0, 0.0),
  )

  let first = new_l_node(graph=Some(graph))
  first.set_type(layer_size_and_graph_height_test_node_type("EXTERNAL_PORT"))
  first.set_layer(Some(layer))
  ignore(first.get_position().set_xy(0.0, 20.0))
  ignore(first.get_size().set_xy(10.0, 10.0))
  first.get_margin().set_values(1.0, 0.0, 1.0, 0.0)

  let second = new_l_node(graph=Some(graph))
  second.set_type(layer_size_and_graph_height_test_node_type("EXTERNAL_PORT"))
  second.set_layer(Some(layer))
  ignore(second.get_position().set_xy(0.0, 40.0))
  ignore(second.get_size().set_xy(10.0, 10.0))
  second.get_margin().set_values(0.0, 0.0, 2.0, 0.0)

  let processor = new_layer_size_and_graph_height_calculator_layout_processor()
  processor.process(graph, None)

  assert_eq(layer.get_size().y, 43.0)
  assert_eq(graph.get_size().y, 43.0)
  assert_eq(graph.get_offset().y, -15.0)
}
