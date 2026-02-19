///|
fn dummy_self_loop_test_side_equals(left : @core.PortSide, right : @core.PortSide) -> Bool {
  @core.port_side_to_string(left) == @core.port_side_to_string(right)
}

///|
fn dummy_self_loop_test_port_side(name : String) -> @core.PortSide {
  for side in @core.port_side_values() {
    if @core.port_side_to_string(side) == name {
      return side
    }
  }
  abort("unknown port side")
}

///|
fn dummy_self_loop_test_node_type(name : String) -> NodeType {
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
fn dummy_self_loop_test_node_type_equals(
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
fn dummy_self_loop_test_require_source(edge : LEdge) -> LPort {
  match edge.get_source() {
    Some(port) => port
    None => abort("edge has no source port")
  }
}

///|
fn dummy_self_loop_test_require_target(edge : LEdge) -> LPort {
  match edge.get_target() {
    Some(port) => port
    None => abort("edge has no target port")
  }
}

///|
fn dummy_self_loop_test_require_node(port : LPort) -> LNode {
  match port.get_node() {
    Some(node) => node
    None => abort("port has no owner node")
  }
}

///|
fn dummy_self_loop_test_find_port(node : LNode, side : @core.PortSide) -> LPort {
  for port in node.get_ports() {
    if dummy_self_loop_test_side_equals(port.get_side(), side) {
      return port
    }
  }
  abort("missing port on expected side")
}

///|
fn dummy_self_loop_test_new_graph_with_single_node() -> (LGraph, Layer, LNode) {
  let graph = new_l_graph()
  let layer = new_layer(graph)
  graph.get_layers().push(layer)

  let node = new_l_node(graph=Some(graph))
  node.set_layer(Some(layer))
  (graph, layer, node)
}

///|
fn dummy_self_loop_test_connect_self_loop(
  node : LNode,
  source_side : @core.PortSide,
  target_side : @core.PortSide,
) -> (LEdge, LPort, LPort) {
  let source = new_l_port()
  source.set_side(source_side)
  source.set_node(Some(node))

  let target = new_l_port()
  target.set_side(target_side)
  target.set_node(Some(node))

  let edge = new_l_edge()
  edge.set_source(Some(source))
  edge.set_target(Some(target))
  (edge, source, target)
}

///|
fn dummy_self_loop_test_count_long_edge_nodes(layer : Layer) -> (Int, LNode?) {
  let mut count = 0
  let mut found : LNode? = None
  for node in layer.get_nodes() {
    if dummy_self_loop_test_node_type_equals(
        node.get_type(),
        dummy_self_loop_test_node_type("LONG_EDGE"),
      ) {
      count = count + 1
      found = Some(node)
    }
  }
  (count, found)
}

///|
test "dummy self loop processor reports expected task name" {
  let processor = new_dummy_self_loop_processor_layout_processor()
  let monitor = new_elk_progress_monitor()
  processor.process(new_l_graph(), Some(monitor))
  inspect(monitor.get_task_name(), content="Self-loop processing")
}

///|
test "dummy self loop processor inserts dummy for west to east self loop" {
  let (graph, layer, node) = dummy_self_loop_test_new_graph_with_single_node()
  let (edge, west_port, east_port) = dummy_self_loop_test_connect_self_loop(
    node,
    dummy_self_loop_test_port_side("WEST"),
    dummy_self_loop_test_port_side("EAST"),
  )

  let processor = new_dummy_self_loop_processor_layout_processor()
  processor.process(graph, None)

  let (dummy_count, dummy_opt) = dummy_self_loop_test_count_long_edge_nodes(
    layer,
  )
  assert_eq(dummy_count, 1)

  let dummy = match dummy_opt {
    Some(value) => value
    None => abort("dummy node missing")
  }

  assert_eq(
    dummy_self_loop_test_require_source(edge).get_handle(),
    west_port.get_handle(),
  )
  assert_eq(
    dummy_self_loop_test_require_node(dummy_self_loop_test_require_target(edge)).get_handle(),
    dummy.get_handle(),
  )

  let long_edge_source = match
    dummy.get_property_l_port(internal_properties_long_edge_source) {
    Some(value) => value
    None => abort("missing LONG_EDGE_SOURCE")
  }
  let long_edge_target = match
    dummy.get_property_l_port(internal_properties_long_edge_target) {
    Some(value) => value
    None => abort("missing LONG_EDGE_TARGET")
  }
  assert_eq(long_edge_source.get_handle(), west_port.get_handle())
  assert_eq(long_edge_target.get_handle(), east_port.get_handle())

  let dummy_output = dummy_self_loop_test_find_port(
    dummy,
    dummy_self_loop_test_port_side("EAST"),
  )
  assert_eq(dummy_output.get_outgoing_edges().length(), 1)
  assert_eq(
    dummy_self_loop_test_require_target(dummy_output.get_outgoing_edges()[0]).get_handle(),
    east_port.get_handle(),
  )
}

///|
test "dummy self loop processor reverses and inserts dummy for east to west self loop" {
  let (graph, layer, node) = dummy_self_loop_test_new_graph_with_single_node()
  let (edge, east_port, west_port) = dummy_self_loop_test_connect_self_loop(
    node,
    dummy_self_loop_test_port_side("EAST"),
    dummy_self_loop_test_port_side("WEST"),
  )

  let processor = new_dummy_self_loop_processor_layout_processor()
  processor.process(graph, None)

  let (dummy_count, dummy_opt) = dummy_self_loop_test_count_long_edge_nodes(
    layer,
  )
  assert_eq(dummy_count, 1)
  assert_true(edge.get_property_bool(internal_properties_reversed))

  let dummy = match dummy_opt {
    Some(value) => value
    None => abort("dummy node missing")
  }

  assert_eq(
    dummy_self_loop_test_require_source(edge).get_handle(),
    west_port.get_handle(),
  )
  assert_eq(
    dummy_self_loop_test_require_node(dummy_self_loop_test_require_target(edge)).get_handle(),
    dummy.get_handle(),
  )

  let long_edge_source = match
    dummy.get_property_l_port(internal_properties_long_edge_source) {
    Some(value) => value
    None => abort("missing LONG_EDGE_SOURCE")
  }
  let long_edge_target = match
    dummy.get_property_l_port(internal_properties_long_edge_target) {
    Some(value) => value
    None => abort("missing LONG_EDGE_TARGET")
  }
  assert_eq(long_edge_source.get_handle(), west_port.get_handle())
  assert_eq(long_edge_target.get_handle(), east_port.get_handle())

  let dummy_output = dummy_self_loop_test_find_port(
    dummy,
    dummy_self_loop_test_port_side("EAST"),
  )
  assert_eq(dummy_output.get_outgoing_edges().length(), 1)
  assert_eq(
    dummy_self_loop_test_require_target(dummy_output.get_outgoing_edges()[0]).get_handle(),
    east_port.get_handle(),
  )
}
