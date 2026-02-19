///|
fn single_edge_wrapper_test_port_side(name : String) -> PortSide {
  for side in port_side_values() {
    if port_side_to_string(side) == name {
      return side
    }
  }
  abort("unknown port side")
}

///|
fn single_edge_wrapper_test_direction(name : String) -> Direction {
  for value in direction_values() {
    if direction_to_string(value) == name {
      return value
    }
  }
  abort("unknown direction")
}

///|
fn single_edge_wrapper_test_node_type(name : String) -> NodeType {
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
fn single_edge_wrapper_test_node_type_equals(
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
fn single_edge_wrapper_test_connect(source : LNode, target : LNode) -> LEdge {
  let source_port = new_l_port()
  source_port.set_side(single_edge_wrapper_test_port_side("EAST"))
  source_port.set_node(Some(source))

  let target_port = new_l_port()
  target_port.set_side(single_edge_wrapper_test_port_side("WEST"))
  target_port.set_node(Some(target))

  let edge = new_l_edge()
  edge.set_source(Some(source_port))
  edge.set_target(Some(target_port))
  edge
}

///|
fn single_edge_wrapper_test_new_path_graph(
  layer_count : Int,
) -> (LGraph, Array[Layer], Array[LNode]) {
  let graph = new_l_graph()
  graph.set_property_direction(
    layered_components_direction,
    single_edge_wrapper_test_direction("RIGHT"),
  )
  graph.set_property_double(aspect_ratio, 1.0)
  graph.set_property_double(layered_options_wrapping_correction_factor, 1.0)
  graph.set_property_double(
    layered_options_spacing_node_node_between_layers, 0.0,
  )
  graph.set_property_double(spacing_node_node, 0.0)
  graph.set_property_double(spacing_edge_node, 0.0)
  graph.set_property_double(
    layered_options_wrapping_additional_edge_spacing, 0.0,
  )

  let layers = []
  let nodes = []
  for _ in 0..<layer_count {
    let layer = new_layer(graph)
    graph.get_layers().push(layer)
    layers.push(layer)

    let node = new_l_node(graph=Some(graph))
    node.set_layer(Some(layer))
    ignore(node.get_size().set_xy(10.0, 10.0))
    nodes.push(node)
  }

  for i in 0..<(layer_count - 1) {
    ignore(single_edge_wrapper_test_connect(nodes[i], nodes[i + 1]))
  }

  (graph, layers, nodes)
}

///|
fn single_edge_wrapper_test_new_validify_graph_stats() -> GraphStats {
  let (graph, layers, nodes) = single_edge_wrapper_test_new_path_graph(6)

  let layer2_extra = new_l_node(graph=Some(graph))
  layer2_extra.set_layer(Some(layers[2]))
  ignore(layer2_extra.get_size().set_xy(10.0, 10.0))
  ignore(single_edge_wrapper_test_connect(nodes[1], layer2_extra))

  let layer4_extra = new_l_node(graph=Some(graph))
  layer4_extra.set_layer(Some(layers[4]))
  ignore(layer4_extra.get_size().set_xy(10.0, 10.0))
  ignore(single_edge_wrapper_test_connect(nodes[3], layer4_extra))

  new_graph_stats(graph)
}

///|
test "single edge graph wrapper reports expected task name" {
  let processor = new_single_edge_graph_wrapper_layout_processor()
  let monitor = new_elk_progress_monitor()
  processor.process(new_l_graph(), Some(monitor))
  inspect(monitor.get_task_name(), content="Path-Like Graph Wrapping")
}

///|
test "single edge graph wrapper greedy validify shifts cuts to next valid index" {
  let graph_stats = single_edge_wrapper_test_new_validify_graph_stats()

  let cuts = single_edge_graph_wrapper_validify_indexes_greedily(graph_stats, [
    2, 4,
  ])
  assert_eq(cuts.length(), 2)
  assert_eq(cuts[0], 3)
  assert_eq(cuts[1], 5)
}

///|
test "single edge graph wrapper look-back validify chooses closest prior valid cuts with offset" {
  let graph_stats = single_edge_wrapper_test_new_validify_graph_stats()

  let cuts = single_edge_graph_wrapper_validify_indexes_looking_back(
    graph_stats,
    [2, 4],
  )
  assert_eq(cuts.length(), 2)
  assert_eq(cuts[0], 1)
  assert_eq(cuts[1], 3)
}

///|
test "single edge graph wrapper manual cuts move nodes and insert long-edge dummies" {
  let (graph, _layers, _nodes) = single_edge_wrapper_test_new_path_graph(4)
  graph.set_property_string(layered_options_wrapping_cutting_strategy, "MANUAL")
  graph.set_property_string(layered_options_wrapping_cutting_cuts, "[2]")
  graph.set_property_string(layered_options_wrapping_validify_strategy, "NO")

  let processor = new_single_edge_graph_wrapper_layout_processor()
  processor.process(graph, None)

  assert_eq(graph.get_layers().length(), 2)
  assert_eq(graph.get_layers()[0].get_nodes().length(), 3)
  assert_eq(graph.get_layers()[1].get_nodes().length(), 3)
  assert_true(graph.get_property_bool(internal_properties_cyclic))

  let mut long_edge_dummy_count = 0
  for layer in graph.get_layers() {
    for node in layer.get_nodes() {
      if single_edge_wrapper_test_node_type_equals(
          node.get_type(),
          single_edge_wrapper_test_node_type("LONG_EDGE"),
        ) {
        long_edge_dummy_count = long_edge_dummy_count + 1
      }
    }
  }
  assert_eq(long_edge_dummy_count, 2)
}
