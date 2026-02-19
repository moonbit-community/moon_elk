///|
fn layer_constraint_processor_test_constraint(node : LNode) -> LayerConstraint {
  layer_constraint_from_string(
    node.get_property_string(layered_options_layering_layer_constraint),
  )
}

///|
fn layer_constraint_processor_test_new_node(
  graph : LGraph,
  constraint : String,
) -> LNode {
  let node = new_l_node(graph=Some(graph))
  if constraint != "NONE" {
    node.set_property_string(
      layered_options_layering_layer_constraint, constraint,
    )
  }
  graph.get_layerless_nodes().push(node)
  node
}

///|
fn layer_constraint_processor_test_port_side(name : String) -> @core.PortSide {
  for side in @core.port_side_values() {
    if @core.port_side_to_string(side) == name {
      return side
    }
  }
  abort("unknown port side")
}

///|
fn layer_constraint_processor_test_new_port(
  node : LNode,
  side : @core.PortSide,
) -> LPort {
  let port = new_l_port()
  port.set_side(side)
  port.set_node(Some(node))
  port
}

///|
fn layer_constraint_processor_test_new_edge(
  source : LPort,
  target : LPort,
) -> LEdge {
  let edge = new_l_edge()
  edge.set_source(Some(source))
  edge.set_target(Some(target))
  edge
}

///|
fn[T] layer_constraint_processor_test_option_is_some(value : T?) -> Bool {
  match value {
    Some(_) => true
    None => false
  }
}

///|
fn layer_constraint_processor_test_collect_layer_positions(
  graph : LGraph,
) -> (Array[Int], Array[Int], Array[Int], Array[Int], Array[Int]) {
  let first_separate_layers = []
  let first_layers = []
  let none_layers = []
  let last_layers = []
  let last_separate_layers = []

  for layer_index in 0..<graph.get_layers().length() {
    for node in graph.get_layers()[layer_index].get_nodes() {
      match layer_constraint_processor_test_constraint(node) {
        LayerConstraint::FirstSeparate =>
          first_separate_layers.push(layer_index)
        LayerConstraint::First => first_layers.push(layer_index)
        LayerConstraint::Last => last_layers.push(layer_index)
        LayerConstraint::LastSeparate => last_separate_layers.push(layer_index)
        LayerConstraint::NoneType => none_layers.push(layer_index)
      }
    }
  }

  (
    first_separate_layers, first_layers, none_layers, last_layers, last_separate_layers,
  )
}

///|
test "layer constraint processors report expected task names" {
  let preprocessor = new_layer_constraint_preprocessor_layout_processor()
  let postprocessor = new_layer_constraint_postprocessor_layout_processor()

  let pre_monitor = new_elk_progress_monitor()
  preprocessor.process(new_l_graph(), Some(pre_monitor))
  inspect(pre_monitor.get_task_name(), content="Layer constraint preprocessing")

  let post_monitor = new_elk_progress_monitor()
  postprocessor.process(new_l_graph(), Some(post_monitor))
  inspect(
    post_monitor.get_task_name(),
    content="Layer constraint postprocessing",
  )
}

///|
test "layer constraint processors satisfy layer rules and keep layers non-empty" {
  let graph = new_l_graph()
  let preprocessor = new_layer_constraint_preprocessor_layout_processor()
  let postprocessor = new_layer_constraint_postprocessor_layout_processor()

  let first_separate = layer_constraint_processor_test_new_node(
    graph, "FIRST_SEPARATE",
  )
  let first = layer_constraint_processor_test_new_node(graph, "FIRST")
  let middle = layer_constraint_processor_test_new_node(graph, "NONE")
  let last = layer_constraint_processor_test_new_node(graph, "LAST")
  let last_separate = layer_constraint_processor_test_new_node(
    graph, "LAST_SEPARATE",
  )

  let first_separate_out = layer_constraint_processor_test_new_port(
    first_separate,
    layer_constraint_processor_test_port_side("EAST"),
  )
  let first_in = layer_constraint_processor_test_new_port(
    first,
    layer_constraint_processor_test_port_side("WEST"),
  )
  let first_out = layer_constraint_processor_test_new_port(
    first,
    layer_constraint_processor_test_port_side("EAST"),
  )
  let middle_in = layer_constraint_processor_test_new_port(
    middle,
    layer_constraint_processor_test_port_side("WEST"),
  )
  let middle_out = layer_constraint_processor_test_new_port(
    middle,
    layer_constraint_processor_test_port_side("EAST"),
  )
  let last_in = layer_constraint_processor_test_new_port(
    last,
    layer_constraint_processor_test_port_side("WEST"),
  )
  let last_out = layer_constraint_processor_test_new_port(
    last,
    layer_constraint_processor_test_port_side("EAST"),
  )
  let last_separate_in = layer_constraint_processor_test_new_port(
    last_separate,
    layer_constraint_processor_test_port_side("WEST"),
  )

  let edge_0 = layer_constraint_processor_test_new_edge(
    first_separate_out, first_in,
  )
  let edge_1 = layer_constraint_processor_test_new_edge(first_out, middle_in)
  let edge_2 = layer_constraint_processor_test_new_edge(middle_out, last_in)
  let edge_3 = layer_constraint_processor_test_new_edge(
    last_out, last_separate_in,
  )

  preprocessor.process(graph, None)

  assert_true(graph.has_property_l_node_array(internal_properties_hidden_nodes))
  assert_eq(
    graph.get_property_l_node_array(internal_properties_hidden_nodes).length(),
    2,
  )

  let layer_0 = new_layer(graph)
  let layer_1 = new_layer(graph)
  let layer_2 = new_layer(graph)
  graph.get_layers().push(layer_0)
  graph.get_layers().push(layer_1)
  graph.get_layers().push(layer_2)
  middle.set_layer(Some(layer_0))
  first.set_layer(Some(layer_1))
  last.set_layer(Some(layer_2))

  postprocessor.process(graph, None)

  let (
    first_separate_layers,
    first_layers,
    none_layers,
    last_layers,
    last_separate_layers,
  ) = layer_constraint_processor_test_collect_layer_positions(graph)

  assert_eq(first_separate_layers.length(), 1)
  assert_eq(first_separate_layers[0], 0)
  assert_false(none_layers.contains(0))

  assert_eq(first_layers.length(), 1)
  assert_eq(first_layers[0], 1)

  let last_layer_index = graph.get_layers().length() - 1
  assert_eq(last_separate_layers.length(), 1)
  assert_eq(last_separate_layers[0], last_layer_index)
  assert_false(none_layers.contains(last_layer_index))

  assert_eq(last_layers.length(), 1)
  assert_eq(last_layers[0], last_layer_index - 1)

  for layer in graph.get_layers() {
    assert_false(layer.get_nodes().is_empty())
  }

  assert_true(
    layer_constraint_processor_test_option_is_some(edge_0.get_source()),
  )
  assert_true(
    layer_constraint_processor_test_option_is_some(edge_0.get_target()),
  )
  assert_true(
    layer_constraint_processor_test_option_is_some(edge_1.get_source()),
  )
  assert_true(
    layer_constraint_processor_test_option_is_some(edge_1.get_target()),
  )
  assert_true(
    layer_constraint_processor_test_option_is_some(edge_2.get_source()),
  )
  assert_true(
    layer_constraint_processor_test_option_is_some(edge_2.get_target()),
  )
  assert_true(
    layer_constraint_processor_test_option_is_some(edge_3.get_source()),
  )
  assert_true(
    layer_constraint_processor_test_option_is_some(edge_3.get_target()),
  )
}

///|
test "layer constraint preprocessor propagates FIRST and LAST to isolated opposite nodes" {
  let graph = new_l_graph()
  let preprocessor = new_layer_constraint_preprocessor_layout_processor()

  let first_separate = layer_constraint_processor_test_new_node(
    graph, "FIRST_SEPARATE",
  )
  let only_from_first_separate = layer_constraint_processor_test_new_node(
    graph, "NONE",
  )
  let only_to_last_separate = layer_constraint_processor_test_new_node(
    graph, "NONE",
  )
  let last_separate = layer_constraint_processor_test_new_node(
    graph, "LAST_SEPARATE",
  )

  let first_separate_out = layer_constraint_processor_test_new_port(
    first_separate,
    layer_constraint_processor_test_port_side("EAST"),
  )
  let only_from_first_in = layer_constraint_processor_test_new_port(
    only_from_first_separate,
    layer_constraint_processor_test_port_side("WEST"),
  )
  let only_to_last_out = layer_constraint_processor_test_new_port(
    only_to_last_separate,
    layer_constraint_processor_test_port_side("EAST"),
  )
  let last_separate_in = layer_constraint_processor_test_new_port(
    last_separate,
    layer_constraint_processor_test_port_side("WEST"),
  )

  ignore(
    layer_constraint_processor_test_new_edge(
      first_separate_out, only_from_first_in,
    ),
  )
  ignore(
    layer_constraint_processor_test_new_edge(only_to_last_out, last_separate_in),
  )

  preprocessor.process(graph, None)

  assert_eq(
    layer_constraint_to_string(
      layer_constraint_processor_test_constraint(only_from_first_separate),
    ),
    "FIRST",
  )
  assert_eq(
    layer_constraint_to_string(
      layer_constraint_processor_test_constraint(only_to_last_separate),
    ),
    "LAST",
  )
}

///|
test "panic layer constraint preprocessor rejects incoming edges on FIRST_SEPARATE nodes" {
  let graph = new_l_graph()
  let preprocessor = new_layer_constraint_preprocessor_layout_processor()

  let source = layer_constraint_processor_test_new_node(graph, "NONE")
  let first_separate = layer_constraint_processor_test_new_node(
    graph, "FIRST_SEPARATE",
  )

  let source_out = layer_constraint_processor_test_new_port(
    source,
    layer_constraint_processor_test_port_side("EAST"),
  )
  let first_separate_in = layer_constraint_processor_test_new_port(
    first_separate,
    layer_constraint_processor_test_port_side("WEST"),
  )
  ignore(
    layer_constraint_processor_test_new_edge(source_out, first_separate_in),
  )

  preprocessor.process(graph, None)
}
