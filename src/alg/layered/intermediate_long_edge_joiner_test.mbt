///|
fn long_edge_joiner_test_port_side(name : String) -> @core.PortSide {
  for side in @core.port_side_values() {
    if @core.port_side_to_string(side) == name {
      return side
    }
  }
  abort("unknown port side")
}

///|
fn long_edge_joiner_test_node_type(name : String) -> NodeType {
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
fn long_edge_joiner_test_node_type_equals(
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
fn long_edge_joiner_test_new_node(graph : LGraph, layer : Layer) -> LNode {
  let node = new_l_node(graph=Some(graph))
  node.set_layer(Some(layer))
  node
}

///|
fn long_edge_joiner_test_new_port(node : LNode, side : String) -> LPort {
  let port = new_l_port()
  port.set_side(long_edge_joiner_test_port_side(side))
  port.set_node(Some(node))
  port
}

///|
fn long_edge_joiner_test_new_edge(source : LPort, target : LPort) -> LEdge {
  let edge = new_l_edge()
  edge.set_source(Some(source))
  edge.set_target(Some(target))
  edge
}

///|
fn long_edge_joiner_test_strategy(
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
fn long_edge_joiner_test_require_source(edge : LEdge) -> LPort {
  match edge.get_source() {
    Some(value) => value
    None => abort("edge has no source")
  }
}

///|
fn long_edge_joiner_test_require_target(edge : LEdge) -> LPort {
  match edge.get_target() {
    Some(value) => value
    None => abort("edge has no target")
  }
}

///|
fn long_edge_joiner_test_require_node(port : LPort) -> LNode {
  match port.get_node() {
    Some(value) => value
    None => abort("port has no owner")
  }
}

///|
fn long_edge_joiner_test_build_chain(
  add_unnecessary_bendpoints : Bool,
) -> (LGraph, LNode, LEdge, LEdge, LPort) {
  let graph = new_l_graph()
  graph.set_property_bool(
    layered_options_unnecessary_bendpoints, add_unnecessary_bendpoints,
  )

  let layer0 = new_layer(graph)
  let layer1 = new_layer(graph)
  let layer2 = new_layer(graph)
  graph.get_layers().push(layer0)
  graph.get_layers().push(layer1)
  graph.get_layers().push(layer2)

  let source = long_edge_joiner_test_new_node(graph, layer0)
  let dummy = long_edge_joiner_test_new_node(graph, layer1)
  dummy.set_type(long_edge_joiner_test_node_type("LONG_EDGE"))
  let target = long_edge_joiner_test_new_node(graph, layer2)

  let source_out = long_edge_joiner_test_new_port(source, "EAST")
  let dummy_in = long_edge_joiner_test_new_port(dummy, "WEST")
  let dummy_out = long_edge_joiner_test_new_port(dummy, "EAST")
  let target_in = long_edge_joiner_test_new_port(target, "WEST")

  let surviving_edge = long_edge_joiner_test_new_edge(source_out, dummy_in)
  let dropped_edge = long_edge_joiner_test_new_edge(dummy_out, target_in)
  (graph, dummy, surviving_edge, dropped_edge, target_in)
}

///|
test "long edge joiner reports expected task name" {
  let processor = new_long_edge_joiner_layout_processor()
  let monitor = new_elk_progress_monitor()
  processor.process(new_l_graph(), Some(monitor))
  inspect(monitor.get_task_name(), content="Edge joining")
}

///|
test "long edge joiner removes long-edge dummies from layers" {
  let (graph, _dummy, surviving_edge, dropped_edge, target_in) = long_edge_joiner_test_build_chain(
    false,
  )
  let processor = new_long_edge_joiner_layout_processor()
  processor.process(graph, None)

  for layer in graph.get_layers() {
    for node in layer.get_nodes() {
      assert_false(
        long_edge_joiner_test_node_type_equals(
          node.get_type(),
          long_edge_joiner_test_node_type("LONG_EDGE"),
        ),
      )
    }
  }

  assert_eq(
    long_edge_joiner_test_require_target(surviving_edge).get_handle(),
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
test "long edge joiner join_at merges bend points labels and junction points" {
  let (_graph, dummy, surviving_edge, dropped_edge, _target_in) = long_edge_joiner_test_build_chain(
    true,
  )

  surviving_edge.get_bend_points().add_xy(1.0, 1.0)
  dropped_edge.get_bend_points().add_xy(2.0, 2.0)
  dropped_edge.get_bend_points().add_xy(3.0, 3.0)

  let surviving_label = new_l_label_text("surviving")
  let dropped_label = new_l_label_text("dropped")
  surviving_edge.get_labels().push(surviving_label)
  dropped_edge.get_labels().push(dropped_label)

  let dropped_junctions = @core.new_kvector_chain()
  dropped_junctions.add_xy(4.0, 4.0)
  dropped_edge.set_property_kvector_chain(
    layered_options_junction_points, dropped_junctions,
  )

  long_edge_joiner_join_at(dummy, true)

  assert_eq(surviving_edge.get_bend_points().size(), 4)
  assert_eq(surviving_edge.get_labels().length(), 2)
  assert_eq(surviving_edge.get_labels()[0].get_text(), "surviving")
  assert_eq(surviving_edge.get_labels()[1].get_text(), "dropped")

  assert_true(
    surviving_edge.has_property_kvector_chain(layered_options_junction_points),
  )
  let surviving_junctions = surviving_edge.get_property_kvector_chain(
    layered_options_junction_points,
  )
  assert_eq(surviving_junctions.size(), 1)
  assert_eq(surviving_junctions.get(0).x, 4.0)
  assert_eq(surviving_junctions.get(0).y, 4.0)

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
test "long edge joiner strategy creates long edge joiner processor" {
  let factory = layered_intermediate_processor_factory(
    long_edge_joiner_test_strategy("LONG_EDGE_JOINER"),
  )
  let processor = factory.create()
  let monitor = new_elk_progress_monitor()
  processor.process(new_l_graph(), Some(monitor))
  inspect(monitor.get_task_name(), content="Edge joining")
}
