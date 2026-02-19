///|
fn label_dummy_switcher_test_strategy(
  name : String,
) -> IntermediateProcessorStrategy {
  for strategy in intermediate_processor_strategy_values() {
    if intermediate_processor_strategy_to_string(strategy) == name {
      return strategy
    }
  }
  abort("unknown strategy")
}

///|
fn label_dummy_switcher_test_port_side(name : String) -> @core.PortSide {
  for side in @core.port_side_values() {
    if @core.port_side_to_string(side) == name {
      return side
    }
  }
  abort("unknown port side")
}

///|
fn label_dummy_switcher_test_node_type(name : String) -> NodeType {
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
fn _label_dummy_switcher_test_require_source(edge : LEdge) -> LPort {
  match edge.get_source() {
    Some(value) => value
    None => abort("edge has no source")
  }
}

///|
fn label_dummy_switcher_test_require_target(edge : LEdge) -> LPort {
  match edge.get_target() {
    Some(value) => value
    None => abort("edge has no target")
  }
}

///|
fn label_dummy_switcher_test_require_node(port : LPort) -> LNode {
  match port.get_node() {
    Some(value) => value
    None => abort("port has no owner node")
  }
}

///|
fn label_dummy_switcher_test_require_layer(node : LNode) -> Layer {
  match node.get_layer() {
    Some(value) => value
    None => abort("node has no layer")
  }
}

///|
fn label_dummy_switcher_test_require_single_outgoing_target_node(
  node : LNode,
) -> LNode {
  let outgoing = node.get_outgoing_edges()
  if outgoing.length() != 1 {
    abort("expected exactly one outgoing edge")
  }
  label_dummy_switcher_test_require_node(
    label_dummy_switcher_test_require_target(outgoing[0]),
  )
}

///|
test "label dummy switcher reports expected task name" {
  let processor = new_label_dummy_switcher_layout_processor()
  let monitor = new_elk_progress_monitor()
  processor.process(new_l_graph(), Some(monitor))
  inspect(monitor.get_task_name(), content="Label dummy switching")
}

///|
test "label dummy switcher median placement swaps label dummy into middle layer" {
  let graph = new_l_graph()
  graph.set_property_string(@core.direction, "RIGHT")
  graph.set_property_string(
    layered_options_edge_labels_center_label_placement_strategy, "MEDIAN_LAYER",
  )

  let layer0 = new_layer(graph)
  let layer1 = new_layer(graph)
  let layer2 = new_layer(graph)
  let layer3 = new_layer(graph)
  let layer4 = new_layer(graph)
  graph.get_layers().push(layer0)
  graph.get_layers().push(layer1)
  graph.get_layers().push(layer2)
  graph.get_layers().push(layer3)
  graph.get_layers().push(layer4)

  let source = new_l_node(graph=Some(graph))
  source.set_layer(Some(layer0))

  let label_dummy = new_l_node(graph=Some(graph))
  label_dummy.set_type(label_dummy_switcher_test_node_type("LABEL_NODE"))
  label_dummy.set_layer(Some(layer1))
  ignore(label_dummy.get_size().set_xy(12.0, 6.0))

  let long_2 = new_l_node(graph=Some(graph))
  long_2.set_type(label_dummy_switcher_test_node_type("LONG_EDGE"))
  long_2.set_layer(Some(layer2))

  let long_3 = new_l_node(graph=Some(graph))
  long_3.set_type(label_dummy_switcher_test_node_type("LONG_EDGE"))
  long_3.set_layer(Some(layer3))

  let target = new_l_node(graph=Some(graph))
  target.set_layer(Some(layer4))

  let source_out = new_l_port()
  source_out.set_side(label_dummy_switcher_test_port_side("EAST"))
  source_out.set_node(Some(source))

  let label_in = new_l_port()
  label_in.set_side(label_dummy_switcher_test_port_side("WEST"))
  label_in.set_node(Some(label_dummy))
  let label_out = new_l_port()
  label_out.set_side(label_dummy_switcher_test_port_side("EAST"))
  label_out.set_node(Some(label_dummy))

  let long_2_in = new_l_port()
  long_2_in.set_side(label_dummy_switcher_test_port_side("WEST"))
  long_2_in.set_node(Some(long_2))
  let long_2_out = new_l_port()
  long_2_out.set_side(label_dummy_switcher_test_port_side("EAST"))
  long_2_out.set_node(Some(long_2))

  let long_3_in = new_l_port()
  long_3_in.set_side(label_dummy_switcher_test_port_side("WEST"))
  long_3_in.set_node(Some(long_3))
  let long_3_out = new_l_port()
  long_3_out.set_side(label_dummy_switcher_test_port_side("EAST"))
  long_3_out.set_node(Some(long_3))

  let target_in = new_l_port()
  target_in.set_side(label_dummy_switcher_test_port_side("WEST"))
  target_in.set_node(Some(target))

  let edge_0 = new_l_edge()
  edge_0.set_source(Some(source_out))
  edge_0.set_target(Some(label_in))

  let edge_1 = new_l_edge()
  edge_1.set_source(Some(label_out))
  edge_1.set_target(Some(long_2_in))

  let edge_2 = new_l_edge()
  edge_2.set_source(Some(long_2_out))
  edge_2.set_target(Some(long_3_in))

  let edge_3 = new_l_edge()
  edge_3.set_source(Some(long_3_out))
  edge_3.set_target(Some(target_in))

  let represented_label = new_l_label_text("center")
  label_dummy.set_property_l_label_array(
    internal_properties_represented_labels,
    [represented_label],
  )

  let processor = new_label_dummy_switcher_layout_processor()
  processor.process(graph, None)

  assert_eq(label_dummy_switcher_test_require_layer(label_dummy).get_id(), 2)
  assert_eq(layer1.get_nodes().length(), 1)
  assert_eq(layer1.get_nodes()[0].get_handle(), long_2.get_handle())
  assert_true(
    represented_label.get_property_bool(label_dummy_switcher_include_label),
  )
  assert_true(
    long_2.get_property_bool(internal_properties_long_edge_before_label_dummy),
  )

  assert_eq(
    label_dummy_switcher_test_require_single_outgoing_target_node(source).get_handle(),
    long_2.get_handle(),
  )
  assert_eq(
    label_dummy_switcher_test_require_single_outgoing_target_node(long_2).get_handle(),
    label_dummy.get_handle(),
  )
  assert_eq(
    label_dummy_switcher_test_require_single_outgoing_target_node(label_dummy).get_handle(),
    long_3.get_handle(),
  )
}

///|
test "label dummy switcher head-layer override moves dummy to edge head and sets @core.alignment" {
  let graph = new_l_graph()
  graph.set_property_string(@core.direction, "RIGHT")
  graph.set_property_string(
    layered_options_edge_labels_center_label_placement_strategy, "MEDIAN_LAYER",
  )

  let layer0 = new_layer(graph)
  let layer1 = new_layer(graph)
  let layer2 = new_layer(graph)
  let layer3 = new_layer(graph)
  let layer4 = new_layer(graph)
  graph.get_layers().push(layer0)
  graph.get_layers().push(layer1)
  graph.get_layers().push(layer2)
  graph.get_layers().push(layer3)
  graph.get_layers().push(layer4)

  let source = new_l_node(graph=Some(graph))
  source.set_layer(Some(layer0))

  let long_left = new_l_node(graph=Some(graph))
  long_left.set_type(label_dummy_switcher_test_node_type("LONG_EDGE"))
  long_left.set_layer(Some(layer1))

  let label_dummy = new_l_node(graph=Some(graph))
  label_dummy.set_type(label_dummy_switcher_test_node_type("LABEL_NODE"))
  label_dummy.set_layer(Some(layer2))
  ignore(label_dummy.get_size().set_xy(10.0, 4.0))

  let long_right = new_l_node(graph=Some(graph))
  long_right.set_type(label_dummy_switcher_test_node_type("LONG_EDGE"))
  long_right.set_layer(Some(layer3))

  let target = new_l_node(graph=Some(graph))
  target.set_layer(Some(layer4))

  let source_out = new_l_port()
  source_out.set_side(label_dummy_switcher_test_port_side("EAST"))
  source_out.set_node(Some(source))

  let long_left_in = new_l_port()
  long_left_in.set_side(label_dummy_switcher_test_port_side("WEST"))
  long_left_in.set_node(Some(long_left))
  let long_left_out = new_l_port()
  long_left_out.set_side(label_dummy_switcher_test_port_side("EAST"))
  long_left_out.set_node(Some(long_left))

  let label_in = new_l_port()
  label_in.set_side(label_dummy_switcher_test_port_side("WEST"))
  label_in.set_node(Some(label_dummy))
  let label_out = new_l_port()
  label_out.set_side(label_dummy_switcher_test_port_side("EAST"))
  label_out.set_node(Some(label_dummy))

  let long_right_in = new_l_port()
  long_right_in.set_side(label_dummy_switcher_test_port_side("WEST"))
  long_right_in.set_node(Some(long_right))
  let long_right_out = new_l_port()
  long_right_out.set_side(label_dummy_switcher_test_port_side("EAST"))
  long_right_out.set_node(Some(long_right))

  let target_in = new_l_port()
  target_in.set_side(label_dummy_switcher_test_port_side("WEST"))
  target_in.set_node(Some(target))

  let edge_0 = new_l_edge()
  edge_0.set_source(Some(source_out))
  edge_0.set_target(Some(long_left_in))

  let edge_1 = new_l_edge()
  edge_1.set_source(Some(long_left_out))
  edge_1.set_target(Some(label_in))

  let edge_2 = new_l_edge()
  edge_2.set_source(Some(label_out))
  edge_2.set_target(Some(long_right_in))

  let edge_3 = new_l_edge()
  edge_3.set_source(Some(long_right_out))
  edge_3.set_target(Some(target_in))

  let represented_label = new_l_label_text("head")
  represented_label.set_property_string(
    layered_options_edge_labels_center_label_placement_strategy, "HEAD_LAYER",
  )
  label_dummy.set_property_l_label_array(
    internal_properties_represented_labels,
    [represented_label],
  )

  let processor = new_label_dummy_switcher_layout_processor()
  processor.process(graph, None)

  assert_eq(label_dummy_switcher_test_require_layer(label_dummy).get_id(), 3)
  assert_eq(layer2.get_nodes().length(), 1)
  assert_eq(layer2.get_nodes()[0].get_handle(), long_right.get_handle())
  assert_eq(label_dummy.get_property_string(@core.alignment), "RIGHT")
  assert_true(
    represented_label.get_property_bool(label_dummy_switcher_include_label),
  )
}

///|
test "label dummy switcher strategy creates concrete processor" {
  let factory = layered_intermediate_processor_factory(
    label_dummy_switcher_test_strategy("LABEL_DUMMY_SWITCHER"),
  )
  let processor = factory.create()
  let monitor = new_elk_progress_monitor()
  processor.process(new_l_graph(), Some(monitor))
  inspect(monitor.get_task_name(), content="Label dummy switching")
}
