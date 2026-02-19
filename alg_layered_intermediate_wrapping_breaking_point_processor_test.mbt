///|
fn breaking_point_processor_test_node_type(name : String) -> NodeType {
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
fn breaking_point_processor_test_port_side(name : String) -> PortSide {
  for side in port_side_values() {
    if port_side_to_string(side) == name {
      return side
    }
  }
  abort("unknown side")
}

///|
fn breaking_point_processor_test_node_type_equals(
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
fn breaking_point_processor_test_add_port(node : LNode, side : String) -> LPort {
  let port = new_l_port()
  port.set_node(Some(node))
  port.set_side(breaking_point_processor_test_port_side(side))
  port
}

///|
fn breaking_point_processor_test_connect(
  source : LNode,
  target : LNode,
) -> LEdge {
  let source_port = breaking_point_processor_test_add_port(source, "EAST")
  let target_port = breaking_point_processor_test_add_port(target, "WEST")
  let edge = new_l_edge()
  edge.set_source(Some(source_port))
  edge.set_target(Some(target_port))
  edge
}

///|
fn breaking_point_processor_test_new_graph() -> LGraph {
  let graph = new_l_graph()
  let layers = []
  let nodes = []

  for _ in 0..<4 {
    let layer = new_layer(graph)
    graph.get_layers().push(layer)
    layers.push(layer)

    let node = new_l_node(graph=Some(graph))
    node.set_layer(Some(layer))
    nodes.push(node)
  }

  for i in 0..<3 {
    ignore(breaking_point_processor_test_connect(nodes[i], nodes[i + 1]))
  }

  graph.set_property_string(layered_options_wrapping_cutting_strategy, "MANUAL")
  graph.set_property_string(layered_options_wrapping_cutting_cuts, "[2]")
  graph.set_property_bool(
    layered_options_wrapping_multi_edge_improve_cuts, false,
  )
  graph.set_property_string(layered_options_wrapping_validify_strategy, "NO")
  graph.set_property_bool(
    layered_options_wrapping_multi_edge_improve_wrapped_edges, false,
  )

  let inserter = new_breaking_point_inserter_layout_processor()
  inserter.process(graph, None)

  graph
}

///|
test "breaking point processor reports expected task name" {
  let processor = new_breaking_point_processor_layout_processor()
  let monitor = new_elk_progress_monitor()
  processor.process(new_l_graph(), Some(monitor))
  inspect(monitor.get_task_name(), content="Breaking Point Processor")
}

///|
test "breaking point processor wraps layers and creates in-layer dummy metadata" {
  let graph = breaking_point_processor_test_new_graph()

  let mut start_dummy : LNode? = None
  let mut end_dummy : LNode? = None
  for layer in graph.get_layers() {
    for node in layer.get_nodes() {
      if bp_info_is_start(node) {
        start_dummy = Some(node)
      }
      if bp_info_is_end(node) {
        end_dummy = Some(node)
      }
    }
  }
  let start = match start_dummy {
    Some(value) => value
    None => abort("missing breaking-point start dummy")
  }
  let end = match end_dummy {
    Some(value) => value
    None => abort("missing breaking-point end dummy")
  }

  let processor = new_breaking_point_processor_layout_processor()
  processor.process(graph, None)

  assert_true(graph.get_property_bool(internal_properties_cyclic))

  let info = match
    start.get_property_bp_info(internal_properties_breaking_point_info) {
    Some(value) => value
    None => abort("missing BPInfo after wrapping")
  }
  assert_true(info.start_in_layer_dummy is Some(_))
  assert_true(info.start_in_layer_edge is Some(_))
  assert_true(info.end_in_layer_dummy is Some(_))
  assert_true(info.end_in_layer_edge is Some(_))

  let mut long_edge_dummy_count = 0
  for layer in graph.get_layers() {
    for node in layer.get_nodes() {
      if breaking_point_processor_test_node_type_equals(
          node.get_type(),
          breaking_point_processor_test_node_type("LONG_EDGE"),
        ) {
        long_edge_dummy_count = long_edge_dummy_count + 1
      }
    }
  }
  assert_true(long_edge_dummy_count > 0)

  assert_true(start.get_layer() is Some(_))
  assert_true(end.get_layer() is Some(_))
}
