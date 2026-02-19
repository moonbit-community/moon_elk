///|
fn label_dummy_remover_test_strategy(
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
fn label_dummy_remover_test_port_side(name : String) -> @core.PortSide {
  for side in @core.port_side_values() {
    if @core.port_side_to_string(side) == name {
      return side
    }
  }
  abort("unknown port side")
}

///|
fn label_dummy_remover_test_node_type(name : String) -> NodeType {
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
fn label_dummy_remover_test_node_type_equals(
  left : NodeType,
  right : NodeType,
) -> Bool {
  match (left, right) {
    (NodeType::Normal, NodeType::Normal) => true
    (NodeType::LongEdge, NodeType::LongEdge) => true
    (NodeType::ExternalPort, NodeType::ExternalPort) => true
    (NodeType::NorthSouthPort, NodeType::NorthSouthPort) => true
    (NodeType::LabelNode, NodeType::LabelNode) => true
    (NodeType::BreakingPoint, NodeType::BreakingPoint) => true
    (NodeType::Placeholder, NodeType::Placeholder) => true
    (NodeType::NonshiftingPlaceholder, NodeType::NonshiftingPlaceholder) => true
    _ => false
  }
}

///|
fn label_dummy_remover_test_require_target(edge : LEdge) -> LPort {
  match edge.get_target() {
    Some(value) => value
    None => abort("edge has no target")
  }
}

///|
fn label_dummy_remover_test_build_graph() -> (
  LGraph,
  LNode,
  LEdge,
  LEdge,
  LPort,
  LLabel,
  LLabel,
) {
  let graph = new_l_graph()
  let layer0 = new_layer(graph)
  let layer1 = new_layer(graph)
  let layer2 = new_layer(graph)
  graph.get_layers().push(layer0)
  graph.get_layers().push(layer1)
  graph.get_layers().push(layer2)

  let source = new_l_node(graph=Some(graph))
  source.set_layer(Some(layer0))
  let dummy = new_l_node(graph=Some(graph))
  dummy.set_type(label_dummy_remover_test_node_type("LABEL_NODE"))
  dummy.set_layer(Some(layer1))
  ignore(dummy.get_position().set_xy(10.0, 20.0))
  ignore(dummy.get_size().set_xy(8.0, 12.0))
  let target = new_l_node(graph=Some(graph))
  target.set_layer(Some(layer2))

  let source_out = new_l_port()
  source_out.set_side(label_dummy_remover_test_port_side("EAST"))
  source_out.set_node(Some(source))
  let dummy_in = new_l_port()
  dummy_in.set_side(label_dummy_remover_test_port_side("WEST"))
  dummy_in.set_node(Some(dummy))
  let dummy_out = new_l_port()
  dummy_out.set_side(label_dummy_remover_test_port_side("EAST"))
  dummy_out.set_node(Some(dummy))
  let target_in = new_l_port()
  target_in.set_side(label_dummy_remover_test_port_side("WEST"))
  target_in.set_node(Some(target))

  let origin_edge = new_l_edge()
  origin_edge.set_source(Some(source_out))
  origin_edge.set_target(Some(dummy_in))
  origin_edge.set_property_double(@core.edge_thickness, 1.0)

  let dropped_edge = new_l_edge()
  dropped_edge.set_source(Some(dummy_out))
  dropped_edge.set_target(Some(target_in))

  let label1 = new_l_label_text("l1")
  ignore(label1.get_size().set_xy(4.0, 2.0))
  let label2 = new_l_label_text("l2")
  ignore(label2.get_size().set_xy(2.0, 3.0))

  dummy.set_property_l_edge(
    internal_properties_origin_l_edge,
    Some(origin_edge),
  )
  dummy.set_property_l_label_array(internal_properties_represented_labels, [
    label1, label2,
  ])

  (graph, dummy, origin_edge, dropped_edge, target_in, label1, label2)
}

///|
test "label dummy remover reports expected task name" {
  let processor = new_label_dummy_remover_layout_processor()
  let monitor = new_elk_progress_monitor()
  processor.process(new_l_graph(), Some(monitor))
  inspect(monitor.get_task_name(), content="Label dummy removal")
}

///|
test "label dummy remover removes label nodes and rejoins original edge" {
  let (graph, _dummy, origin_edge, dropped_edge, target_in, label1, label2) = label_dummy_remover_test_build_graph()

  let processor = new_label_dummy_remover_layout_processor()
  processor.process(graph, None)

  for layer in graph.get_layers() {
    for node in layer.get_nodes() {
      assert_false(
        label_dummy_remover_test_node_type_equals(
          node.get_type(),
          label_dummy_remover_test_node_type("LABEL_NODE"),
        ),
      )
    }
  }

  assert_eq(origin_edge.get_labels().length(), 2)
  assert_eq(origin_edge.get_labels()[0].get_text(), "l1")
  assert_eq(origin_edge.get_labels()[1].get_text(), "l2")
  assert_eq(label1.get_position().x, 12.0)
  assert_eq(label1.get_position().y, 20.0)
  assert_eq(label2.get_position().x, 13.0)
  assert_eq(label2.get_position().y, 22.0)

  assert_eq(
    label_dummy_remover_test_require_target(origin_edge).get_handle(),
    target_in.get_handle(),
  )
  assert_true(
    match dropped_edge.get_source() {
      Some(_) => false
      None => true
    },
  )
  assert_true(
    match dropped_edge.get_target() {
      Some(_) => false
      None => true
    },
  )
}

///|
test "label dummy remover vertical up places inline labels in reversed order" {
  let (graph, dummy, origin_edge, _dropped_edge, _target_in, label1, label2) = label_dummy_remover_test_build_graph()
  graph.set_property_string(@core.direction, "UP")
  ignore(dummy.get_position().set_xy(30.0, 40.0))
  ignore(dummy.get_size().set_xy(20.0, 10.0))
  ignore(label1.get_size().set_xy(3.0, 2.0))
  ignore(label2.get_size().set_xy(5.0, 2.0))
  label1.set_property_bool(@core.edge_labels_inline, true)
  label2.set_property_bool(@core.edge_labels_inline, true)

  let processor = new_label_dummy_remover_layout_processor()
  processor.process(graph, None)

  assert_eq(origin_edge.get_labels().length(), 2)
  assert_eq(label2.get_position().x, 30.0)
  assert_eq(label1.get_position().x, 35.0)
  assert_eq(label1.get_position().y, 44.0)
  assert_eq(label2.get_position().y, 44.0)
}

///|
test "label dummy remover strategy creates concrete processor" {
  let factory = layered_intermediate_processor_factory(
    label_dummy_remover_test_strategy("LABEL_DUMMY_REMOVER"),
  )
  let processor = factory.create()
  let monitor = new_elk_progress_monitor()
  processor.process(new_l_graph(), Some(monitor))
  inspect(monitor.get_task_name(), content="Label dummy removal")
}
