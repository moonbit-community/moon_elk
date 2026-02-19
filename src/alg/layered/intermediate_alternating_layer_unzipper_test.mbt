///|
fn alternating_layer_unzipper_test_node_type_equals(
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
fn alternating_layer_unzipper_test_node_type(name : String) -> NodeType {
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
fn alternating_layer_unzipper_test_port_side(name : String) -> @core.PortSide {
  for side in @core.port_side_values() {
    if @core.port_side_to_string(side) == name {
      return side
    }
  }
  abort("unknown port side")
}

///|
fn alternating_layer_unzipper_test_strategy(
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
fn alternating_layer_unzipper_test_require_layer(node : LNode) -> Layer {
  match node.get_layer() {
    Some(value) => value
    None => abort("node has no layer")
  }
}

///|
fn alternating_layer_unzipper_test_layer_index(node : LNode) -> Int {
  alternating_layer_unzipper_test_require_layer(node).get_index()
}

///|
fn alternating_layer_unzipper_test_new_node(
  graph : LGraph,
  layer : Layer,
  node_type : NodeType,
) -> LNode {
  let node = new_l_node(graph=Some(graph))
  node.set_type(node_type)
  node.set_layer(Some(layer))
  node
}

///|
fn alternating_layer_unzipper_test_new_edge(
  source : LNode,
  target : LNode,
) -> LEdge {
  let source_port = new_l_port()
  source_port.set_side(alternating_layer_unzipper_test_port_side("EAST"))
  source_port.set_node(Some(source))

  let target_port = new_l_port()
  target_port.set_side(alternating_layer_unzipper_test_port_side("WEST"))
  target_port.set_node(Some(target))

  let edge = new_l_edge()
  edge.set_source(Some(source_port))
  edge.set_target(Some(target_port))
  edge
}

///|
fn alternating_layer_unzipper_test_assert_no_placeholders(
  graph : LGraph,
) -> Unit raise {
  for layer in graph.get_layers() {
    for node in layer.get_nodes() {
      assert_true(
        !alternating_layer_unzipper_test_node_type_equals(
          node.get_type(),
          alternating_layer_unzipper_test_node_type("PLACEHOLDER"),
        ),
      )
      assert_true(
        !alternating_layer_unzipper_test_node_type_equals(
          node.get_type(),
          alternating_layer_unzipper_test_node_type("NONSHIFTING_PLACEHOLDER"),
        ),
      )
    }
  }
}

///|
test "alternating layer unzipper splits one layer in A-B-A order" {
  let graph = new_l_graph()
  let layer0 = new_layer(graph)
  let layer1 = new_layer(graph)
  let layer2 = new_layer(graph)
  graph.get_layers().push(layer0)
  graph.get_layers().push(layer1)
  graph.get_layers().push(layer2)

  let source = alternating_layer_unzipper_test_new_node(
    graph,
    layer0,
    alternating_layer_unzipper_test_node_type("NORMAL"),
  )
  let mid_a = alternating_layer_unzipper_test_new_node(
    graph,
    layer1,
    alternating_layer_unzipper_test_node_type("NORMAL"),
  )
  let mid_b = alternating_layer_unzipper_test_new_node(
    graph,
    layer1,
    alternating_layer_unzipper_test_node_type("NORMAL"),
  )
  let mid_c = alternating_layer_unzipper_test_new_node(
    graph,
    layer1,
    alternating_layer_unzipper_test_node_type("NORMAL"),
  )
  let target = alternating_layer_unzipper_test_new_node(
    graph,
    layer2,
    alternating_layer_unzipper_test_node_type("NORMAL"),
  )

  ignore(alternating_layer_unzipper_test_new_edge(source, mid_a))
  ignore(alternating_layer_unzipper_test_new_edge(source, mid_b))
  ignore(alternating_layer_unzipper_test_new_edge(source, mid_c))
  ignore(alternating_layer_unzipper_test_new_edge(mid_a, target))
  ignore(alternating_layer_unzipper_test_new_edge(mid_b, target))
  ignore(alternating_layer_unzipper_test_new_edge(mid_c, target))

  mid_a.set_property_int(layered_options_layer_unzipping_layer_split, 2)

  let processor = new_alternating_layer_unzipper_layout_processor()
  processor.process(graph, None)

  assert_eq(graph.get_layers().length(), 4)
  assert_eq(
    alternating_layer_unzipper_test_require_layer(source).get_index(),
    0,
  )
  assert_eq(alternating_layer_unzipper_test_require_layer(mid_a).get_index(), 1)
  assert_eq(alternating_layer_unzipper_test_require_layer(mid_b).get_index(), 2)
  assert_eq(alternating_layer_unzipper_test_require_layer(mid_c).get_index(), 1)
  assert_eq(
    alternating_layer_unzipper_test_require_layer(target).get_index(),
    3,
  )
  alternating_layer_unzipper_test_assert_no_placeholders(graph)
}

///|
test "alternating layer unzipper splits one layer in A-B-C-A order" {
  let graph = new_l_graph()
  let layer0 = new_layer(graph)
  let layer1 = new_layer(graph)
  let layer2 = new_layer(graph)
  graph.get_layers().push(layer0)
  graph.get_layers().push(layer1)
  graph.get_layers().push(layer2)

  let source = alternating_layer_unzipper_test_new_node(
    graph,
    layer0,
    alternating_layer_unzipper_test_node_type("NORMAL"),
  )
  let mid_a = alternating_layer_unzipper_test_new_node(
    graph,
    layer1,
    alternating_layer_unzipper_test_node_type("NORMAL"),
  )
  let mid_b = alternating_layer_unzipper_test_new_node(
    graph,
    layer1,
    alternating_layer_unzipper_test_node_type("NORMAL"),
  )
  let mid_c = alternating_layer_unzipper_test_new_node(
    graph,
    layer1,
    alternating_layer_unzipper_test_node_type("NORMAL"),
  )
  let mid_d = alternating_layer_unzipper_test_new_node(
    graph,
    layer1,
    alternating_layer_unzipper_test_node_type("NORMAL"),
  )
  let target = alternating_layer_unzipper_test_new_node(
    graph,
    layer2,
    alternating_layer_unzipper_test_node_type("NORMAL"),
  )

  ignore(alternating_layer_unzipper_test_new_edge(source, mid_a))
  ignore(alternating_layer_unzipper_test_new_edge(source, mid_b))
  ignore(alternating_layer_unzipper_test_new_edge(source, mid_c))
  ignore(alternating_layer_unzipper_test_new_edge(source, mid_d))
  ignore(alternating_layer_unzipper_test_new_edge(mid_a, target))
  ignore(alternating_layer_unzipper_test_new_edge(mid_b, target))
  ignore(alternating_layer_unzipper_test_new_edge(mid_c, target))
  ignore(alternating_layer_unzipper_test_new_edge(mid_d, target))

  mid_a.set_property_int(layered_options_layer_unzipping_layer_split, 3)

  let processor = new_alternating_layer_unzipper_layout_processor()
  processor.process(graph, None)

  assert_eq(alternating_layer_unzipper_test_layer_index(source), 0)
  assert_eq(alternating_layer_unzipper_test_layer_index(mid_a), 1)
  assert_eq(alternating_layer_unzipper_test_layer_index(mid_b), 2)
  assert_eq(alternating_layer_unzipper_test_layer_index(mid_c), 3)
  assert_eq(alternating_layer_unzipper_test_layer_index(mid_d), 1)
  assert_eq(alternating_layer_unzipper_test_layer_index(target), 4)
  alternating_layer_unzipper_test_assert_no_placeholders(graph)
}

///|
test "alternating layer unzipper handles dangling outgoing split layers" {
  let graph = new_l_graph()
  let layer0 = new_layer(graph)
  let layer1 = new_layer(graph)
  graph.get_layers().push(layer0)
  graph.get_layers().push(layer1)

  let node1 = alternating_layer_unzipper_test_new_node(
    graph,
    layer0,
    alternating_layer_unzipper_test_node_type("NORMAL"),
  )
  let node2 = alternating_layer_unzipper_test_new_node(
    graph,
    layer1,
    alternating_layer_unzipper_test_node_type("NORMAL"),
  )
  let node3 = alternating_layer_unzipper_test_new_node(
    graph,
    layer1,
    alternating_layer_unzipper_test_node_type("NORMAL"),
  )
  let node4 = alternating_layer_unzipper_test_new_node(
    graph,
    layer1,
    alternating_layer_unzipper_test_node_type("NORMAL"),
  )
  let node5 = alternating_layer_unzipper_test_new_node(
    graph,
    layer1,
    alternating_layer_unzipper_test_node_type("NORMAL"),
  )

  ignore(alternating_layer_unzipper_test_new_edge(node1, node2))
  ignore(alternating_layer_unzipper_test_new_edge(node1, node3))
  ignore(alternating_layer_unzipper_test_new_edge(node1, node4))
  ignore(alternating_layer_unzipper_test_new_edge(node1, node5))

  node2.set_property_int(layered_options_layer_unzipping_layer_split, 2)

  let processor = new_alternating_layer_unzipper_layout_processor()
  processor.process(graph, None)

  assert_true(
    alternating_layer_unzipper_test_layer_index(node1) <
    alternating_layer_unzipper_test_layer_index(node2),
  )
  assert_true(
    alternating_layer_unzipper_test_layer_index(node1) <
    alternating_layer_unzipper_test_layer_index(node4),
  )
  assert_true(
    alternating_layer_unzipper_test_layer_index(node2) <
    alternating_layer_unzipper_test_layer_index(node3),
  )
  assert_true(
    alternating_layer_unzipper_test_layer_index(node2) <
    alternating_layer_unzipper_test_layer_index(node5),
  )
  assert_true(
    alternating_layer_unzipper_test_layer_index(node4) <
    alternating_layer_unzipper_test_layer_index(node3),
  )
  assert_true(
    alternating_layer_unzipper_test_layer_index(node4) <
    alternating_layer_unzipper_test_layer_index(node5),
  )
  alternating_layer_unzipper_test_assert_no_placeholders(graph)
}

///|
test "alternating layer unzipper handles dangling incoming split layers" {
  let graph = new_l_graph()
  let layer0 = new_layer(graph)
  let layer1 = new_layer(graph)
  graph.get_layers().push(layer0)
  graph.get_layers().push(layer1)

  let node1 = alternating_layer_unzipper_test_new_node(
    graph,
    layer0,
    alternating_layer_unzipper_test_node_type("NORMAL"),
  )
  let node2 = alternating_layer_unzipper_test_new_node(
    graph,
    layer0,
    alternating_layer_unzipper_test_node_type("NORMAL"),
  )
  let node3 = alternating_layer_unzipper_test_new_node(
    graph,
    layer0,
    alternating_layer_unzipper_test_node_type("NORMAL"),
  )
  let node4 = alternating_layer_unzipper_test_new_node(
    graph,
    layer0,
    alternating_layer_unzipper_test_node_type("NORMAL"),
  )
  let node5 = alternating_layer_unzipper_test_new_node(
    graph,
    layer0,
    alternating_layer_unzipper_test_node_type("NORMAL"),
  )
  let node_final = alternating_layer_unzipper_test_new_node(
    graph,
    layer1,
    alternating_layer_unzipper_test_node_type("NORMAL"),
  )

  ignore(alternating_layer_unzipper_test_new_edge(node1, node_final))
  ignore(alternating_layer_unzipper_test_new_edge(node2, node_final))
  ignore(alternating_layer_unzipper_test_new_edge(node3, node_final))
  ignore(alternating_layer_unzipper_test_new_edge(node4, node_final))
  ignore(alternating_layer_unzipper_test_new_edge(node5, node_final))

  node2.set_property_int(layered_options_layer_unzipping_layer_split, 2)

  let processor = new_alternating_layer_unzipper_layout_processor()
  processor.process(graph, None)

  assert_true(
    alternating_layer_unzipper_test_layer_index(node1) <
    alternating_layer_unzipper_test_layer_index(node2),
  )
  assert_true(
    alternating_layer_unzipper_test_layer_index(node1) <
    alternating_layer_unzipper_test_layer_index(node4),
  )
  assert_true(
    alternating_layer_unzipper_test_layer_index(node3) <
    alternating_layer_unzipper_test_layer_index(node2),
  )
  assert_true(
    alternating_layer_unzipper_test_layer_index(node3) <
    alternating_layer_unzipper_test_layer_index(node4),
  )
  assert_true(
    alternating_layer_unzipper_test_layer_index(node5) <
    alternating_layer_unzipper_test_layer_index(node2),
  )
  assert_true(
    alternating_layer_unzipper_test_layer_index(node5) <
    alternating_layer_unzipper_test_layer_index(node4),
  )
  assert_true(
    alternating_layer_unzipper_test_layer_index(node2) <
    alternating_layer_unzipper_test_layer_index(node_final),
  )
  assert_true(
    alternating_layer_unzipper_test_layer_index(node4) <
    alternating_layer_unzipper_test_layer_index(node_final),
  )
  alternating_layer_unzipper_test_assert_no_placeholders(graph)
}

///|
test "alternating layer unzipper splits multiple consecutive layers" {
  let graph = new_l_graph()
  let layer0 = new_layer(graph)
  let layer1 = new_layer(graph)
  graph.get_layers().push(layer0)
  graph.get_layers().push(layer1)

  let node1 = alternating_layer_unzipper_test_new_node(
    graph,
    layer0,
    alternating_layer_unzipper_test_node_type("NORMAL"),
  )
  let node2 = alternating_layer_unzipper_test_new_node(
    graph,
    layer0,
    alternating_layer_unzipper_test_node_type("NORMAL"),
  )
  let node3 = alternating_layer_unzipper_test_new_node(
    graph,
    layer0,
    alternating_layer_unzipper_test_node_type("NORMAL"),
  )
  let node4 = alternating_layer_unzipper_test_new_node(
    graph,
    layer0,
    alternating_layer_unzipper_test_node_type("NORMAL"),
  )

  let node21 = alternating_layer_unzipper_test_new_node(
    graph,
    layer1,
    alternating_layer_unzipper_test_node_type("NORMAL"),
  )
  let node22 = alternating_layer_unzipper_test_new_node(
    graph,
    layer1,
    alternating_layer_unzipper_test_node_type("NORMAL"),
  )
  let node23 = alternating_layer_unzipper_test_new_node(
    graph,
    layer1,
    alternating_layer_unzipper_test_node_type("NORMAL"),
  )

  ignore(alternating_layer_unzipper_test_new_edge(node1, node21))
  ignore(alternating_layer_unzipper_test_new_edge(node2, node21))
  ignore(alternating_layer_unzipper_test_new_edge(node2, node22))
  ignore(alternating_layer_unzipper_test_new_edge(node3, node21))
  ignore(alternating_layer_unzipper_test_new_edge(node3, node22))
  ignore(alternating_layer_unzipper_test_new_edge(node4, node22))
  ignore(alternating_layer_unzipper_test_new_edge(node4, node23))

  node1.set_property_int(layered_options_layer_unzipping_layer_split, 2)
  node21.set_property_int(layered_options_layer_unzipping_layer_split, 2)

  let processor = new_alternating_layer_unzipper_layout_processor()
  processor.process(graph, None)

  assert_true(
    alternating_layer_unzipper_test_layer_index(node1) <
    alternating_layer_unzipper_test_layer_index(node2),
  )
  assert_true(
    alternating_layer_unzipper_test_layer_index(node1) <
    alternating_layer_unzipper_test_layer_index(node4),
  )
  assert_true(
    alternating_layer_unzipper_test_layer_index(node3) <
    alternating_layer_unzipper_test_layer_index(node2),
  )
  assert_true(
    alternating_layer_unzipper_test_layer_index(node3) <
    alternating_layer_unzipper_test_layer_index(node4),
  )
  assert_true(
    alternating_layer_unzipper_test_layer_index(node2) <
    alternating_layer_unzipper_test_layer_index(node21),
  )
  assert_true(
    alternating_layer_unzipper_test_layer_index(node2) <
    alternating_layer_unzipper_test_layer_index(node23),
  )
  assert_true(
    alternating_layer_unzipper_test_layer_index(node4) <
    alternating_layer_unzipper_test_layer_index(node21),
  )
  assert_true(
    alternating_layer_unzipper_test_layer_index(node4) <
    alternating_layer_unzipper_test_layer_index(node23),
  )
  assert_true(
    alternating_layer_unzipper_test_layer_index(node21) <
    alternating_layer_unzipper_test_layer_index(node22),
  )
  assert_true(
    alternating_layer_unzipper_test_layer_index(node23) <
    alternating_layer_unzipper_test_layer_index(node22),
  )
  alternating_layer_unzipper_test_assert_no_placeholders(graph)
}

///|
test "alternating layer unzipper handles multiple incoming edges on a split layer" {
  let graph = new_l_graph()
  let layer0 = new_layer(graph)
  let layer1 = new_layer(graph)
  let layer2 = new_layer(graph)
  graph.get_layers().push(layer0)
  graph.get_layers().push(layer1)
  graph.get_layers().push(layer2)

  let source = alternating_layer_unzipper_test_new_node(
    graph,
    layer0,
    alternating_layer_unzipper_test_node_type("NORMAL"),
  )
  let mid_a = alternating_layer_unzipper_test_new_node(
    graph,
    layer1,
    alternating_layer_unzipper_test_node_type("NORMAL"),
  )
  let mid_b = alternating_layer_unzipper_test_new_node(
    graph,
    layer1,
    alternating_layer_unzipper_test_node_type("NORMAL"),
  )
  let mid_c = alternating_layer_unzipper_test_new_node(
    graph,
    layer1,
    alternating_layer_unzipper_test_node_type("NORMAL"),
  )
  let target = alternating_layer_unzipper_test_new_node(
    graph,
    layer2,
    alternating_layer_unzipper_test_node_type("NORMAL"),
  )

  ignore(alternating_layer_unzipper_test_new_edge(source, mid_a))
  ignore(alternating_layer_unzipper_test_new_edge(source, mid_a))
  ignore(alternating_layer_unzipper_test_new_edge(source, mid_a))
  ignore(alternating_layer_unzipper_test_new_edge(source, mid_a))
  ignore(alternating_layer_unzipper_test_new_edge(source, mid_a))
  ignore(alternating_layer_unzipper_test_new_edge(source, mid_b))
  ignore(alternating_layer_unzipper_test_new_edge(source, mid_b))
  ignore(alternating_layer_unzipper_test_new_edge(source, mid_b))
  ignore(alternating_layer_unzipper_test_new_edge(source, mid_b))
  ignore(alternating_layer_unzipper_test_new_edge(source, mid_c))
  ignore(alternating_layer_unzipper_test_new_edge(mid_a, target))
  ignore(alternating_layer_unzipper_test_new_edge(mid_b, target))
  ignore(alternating_layer_unzipper_test_new_edge(mid_c, target))

  mid_a.set_property_int(layered_options_layer_unzipping_layer_split, 2)

  let processor = new_alternating_layer_unzipper_layout_processor()
  processor.process(graph, None)

  assert_eq(alternating_layer_unzipper_test_layer_index(source), 0)
  assert_eq(alternating_layer_unzipper_test_layer_index(mid_a), 1)
  assert_eq(alternating_layer_unzipper_test_layer_index(mid_b), 2)
  assert_eq(alternating_layer_unzipper_test_layer_index(mid_c), 1)
  assert_eq(alternating_layer_unzipper_test_layer_index(target), 3)
  alternating_layer_unzipper_test_assert_no_placeholders(graph)
}

///|
test "alternating layer unzipper handles multiple outgoing edges on a split layer" {
  let graph = new_l_graph()
  let layer0 = new_layer(graph)
  let layer1 = new_layer(graph)
  let layer2 = new_layer(graph)
  graph.get_layers().push(layer0)
  graph.get_layers().push(layer1)
  graph.get_layers().push(layer2)

  let source = alternating_layer_unzipper_test_new_node(
    graph,
    layer0,
    alternating_layer_unzipper_test_node_type("NORMAL"),
  )
  let mid_a = alternating_layer_unzipper_test_new_node(
    graph,
    layer1,
    alternating_layer_unzipper_test_node_type("NORMAL"),
  )
  let mid_b = alternating_layer_unzipper_test_new_node(
    graph,
    layer1,
    alternating_layer_unzipper_test_node_type("NORMAL"),
  )
  let mid_c = alternating_layer_unzipper_test_new_node(
    graph,
    layer1,
    alternating_layer_unzipper_test_node_type("NORMAL"),
  )
  let target = alternating_layer_unzipper_test_new_node(
    graph,
    layer2,
    alternating_layer_unzipper_test_node_type("NORMAL"),
  )

  ignore(alternating_layer_unzipper_test_new_edge(source, mid_a))
  ignore(alternating_layer_unzipper_test_new_edge(source, mid_b))
  ignore(alternating_layer_unzipper_test_new_edge(source, mid_c))
  ignore(alternating_layer_unzipper_test_new_edge(mid_a, target))
  ignore(alternating_layer_unzipper_test_new_edge(mid_a, target))
  ignore(alternating_layer_unzipper_test_new_edge(mid_a, target))
  ignore(alternating_layer_unzipper_test_new_edge(mid_a, target))
  ignore(alternating_layer_unzipper_test_new_edge(mid_b, target))
  ignore(alternating_layer_unzipper_test_new_edge(mid_c, target))
  ignore(alternating_layer_unzipper_test_new_edge(mid_c, target))
  ignore(alternating_layer_unzipper_test_new_edge(mid_c, target))
  ignore(alternating_layer_unzipper_test_new_edge(mid_c, target))

  mid_a.set_property_int(layered_options_layer_unzipping_layer_split, 2)

  let processor = new_alternating_layer_unzipper_layout_processor()
  processor.process(graph, None)

  assert_eq(alternating_layer_unzipper_test_layer_index(source), 0)
  assert_eq(alternating_layer_unzipper_test_layer_index(mid_a), 1)
  assert_eq(alternating_layer_unzipper_test_layer_index(mid_b), 2)
  assert_eq(alternating_layer_unzipper_test_layer_index(mid_c), 1)
  assert_eq(alternating_layer_unzipper_test_layer_index(target), 3)
  alternating_layer_unzipper_test_assert_no_placeholders(graph)
}

///|
test "alternating layer unzipper handles mixed dangling incoming nodes" {
  let graph = new_l_graph()
  let layer0 = new_layer(graph)
  let layer1 = new_layer(graph)
  let layer2 = new_layer(graph)
  graph.get_layers().push(layer0)
  graph.get_layers().push(layer1)
  graph.get_layers().push(layer2)

  let node1 = alternating_layer_unzipper_test_new_node(
    graph,
    layer0,
    alternating_layer_unzipper_test_node_type("NORMAL"),
  )
  let node2 = alternating_layer_unzipper_test_new_node(
    graph,
    layer1,
    alternating_layer_unzipper_test_node_type("NORMAL"),
  )
  let node3 = alternating_layer_unzipper_test_new_node(
    graph,
    layer1,
    alternating_layer_unzipper_test_node_type("NORMAL"),
  )
  let node4 = alternating_layer_unzipper_test_new_node(
    graph,
    layer1,
    alternating_layer_unzipper_test_node_type("NORMAL"),
  )
  let node5 = alternating_layer_unzipper_test_new_node(
    graph,
    layer2,
    alternating_layer_unzipper_test_node_type("NORMAL"),
  )
  let node6 = alternating_layer_unzipper_test_new_node(
    graph,
    layer2,
    alternating_layer_unzipper_test_node_type("NORMAL"),
  )
  let node7 = alternating_layer_unzipper_test_new_node(
    graph,
    layer2,
    alternating_layer_unzipper_test_node_type("NORMAL"),
  )

  ignore(alternating_layer_unzipper_test_new_edge(node1, node3))
  ignore(alternating_layer_unzipper_test_new_edge(node1, node4))
  ignore(alternating_layer_unzipper_test_new_edge(node2, node5))
  ignore(alternating_layer_unzipper_test_new_edge(node3, node5))
  ignore(alternating_layer_unzipper_test_new_edge(node3, node6))
  ignore(alternating_layer_unzipper_test_new_edge(node4, node7))

  node2.set_property_int(layered_options_layer_unzipping_layer_split, 2)
  node5.set_property_int(layered_options_layer_unzipping_layer_split, 2)

  let processor = new_alternating_layer_unzipper_layout_processor()
  processor.process(graph, None)

  assert_true(
    alternating_layer_unzipper_test_layer_index(node1) <
    alternating_layer_unzipper_test_layer_index(node2),
  )
  assert_true(
    alternating_layer_unzipper_test_layer_index(node1) <
    alternating_layer_unzipper_test_layer_index(node4),
  )
  assert_true(
    alternating_layer_unzipper_test_layer_index(node2) <
    alternating_layer_unzipper_test_layer_index(node3),
  )
  assert_true(
    alternating_layer_unzipper_test_layer_index(node4) <
    alternating_layer_unzipper_test_layer_index(node3),
  )
  assert_true(
    alternating_layer_unzipper_test_layer_index(node3) <
    alternating_layer_unzipper_test_layer_index(node5),
  )
  assert_true(
    alternating_layer_unzipper_test_layer_index(node3) <
    alternating_layer_unzipper_test_layer_index(node7),
  )
  assert_true(
    alternating_layer_unzipper_test_layer_index(node5) <
    alternating_layer_unzipper_test_layer_index(node6),
  )
  assert_true(
    alternating_layer_unzipper_test_layer_index(node7) <
    alternating_layer_unzipper_test_layer_index(node6),
  )
  alternating_layer_unzipper_test_assert_no_placeholders(graph)
}

///|
test "alternating layer unzipper handles mixed dangling outgoing nodes" {
  let graph = new_l_graph()
  let layer0 = new_layer(graph)
  let layer1 = new_layer(graph)
  let layer2 = new_layer(graph)
  graph.get_layers().push(layer0)
  graph.get_layers().push(layer1)
  graph.get_layers().push(layer2)

  let node1 = alternating_layer_unzipper_test_new_node(
    graph,
    layer0,
    alternating_layer_unzipper_test_node_type("NORMAL"),
  )
  let node2 = alternating_layer_unzipper_test_new_node(
    graph,
    layer1,
    alternating_layer_unzipper_test_node_type("NORMAL"),
  )
  let node3 = alternating_layer_unzipper_test_new_node(
    graph,
    layer1,
    alternating_layer_unzipper_test_node_type("NORMAL"),
  )
  let node4 = alternating_layer_unzipper_test_new_node(
    graph,
    layer1,
    alternating_layer_unzipper_test_node_type("NORMAL"),
  )
  let node5 = alternating_layer_unzipper_test_new_node(
    graph,
    layer2,
    alternating_layer_unzipper_test_node_type("NORMAL"),
  )
  let node6 = alternating_layer_unzipper_test_new_node(
    graph,
    layer2,
    alternating_layer_unzipper_test_node_type("NORMAL"),
  )
  let node7 = alternating_layer_unzipper_test_new_node(
    graph,
    layer2,
    alternating_layer_unzipper_test_node_type("NORMAL"),
  )

  ignore(alternating_layer_unzipper_test_new_edge(node1, node2))
  ignore(alternating_layer_unzipper_test_new_edge(node1, node3))
  ignore(alternating_layer_unzipper_test_new_edge(node1, node4))
  ignore(alternating_layer_unzipper_test_new_edge(node3, node5))
  ignore(alternating_layer_unzipper_test_new_edge(node3, node6))
  ignore(alternating_layer_unzipper_test_new_edge(node4, node7))

  node2.set_property_int(layered_options_layer_unzipping_layer_split, 2)
  node5.set_property_int(layered_options_layer_unzipping_layer_split, 2)

  let processor = new_alternating_layer_unzipper_layout_processor()
  processor.process(graph, None)

  assert_true(
    alternating_layer_unzipper_test_layer_index(node1) <
    alternating_layer_unzipper_test_layer_index(node2),
  )
  assert_true(
    alternating_layer_unzipper_test_layer_index(node1) <
    alternating_layer_unzipper_test_layer_index(node4),
  )
  assert_true(
    alternating_layer_unzipper_test_layer_index(node2) <
    alternating_layer_unzipper_test_layer_index(node3),
  )
  assert_true(
    alternating_layer_unzipper_test_layer_index(node4) <
    alternating_layer_unzipper_test_layer_index(node3),
  )
  assert_true(
    alternating_layer_unzipper_test_layer_index(node3) <
    alternating_layer_unzipper_test_layer_index(node5),
  )
  assert_true(
    alternating_layer_unzipper_test_layer_index(node3) <
    alternating_layer_unzipper_test_layer_index(node7),
  )
  assert_true(
    alternating_layer_unzipper_test_layer_index(node5) <
    alternating_layer_unzipper_test_layer_index(node6),
  )
  assert_true(
    alternating_layer_unzipper_test_layer_index(node7) <
    alternating_layer_unzipper_test_layer_index(node6),
  )
  alternating_layer_unzipper_test_assert_no_placeholders(graph)
}

///|
test "alternating layer unzipper supports mixed two-way and three-way layer splits" {
  let graph = new_l_graph()
  let layer0 = new_layer(graph)
  let layer1 = new_layer(graph)
  graph.get_layers().push(layer0)
  graph.get_layers().push(layer1)

  let node1 = alternating_layer_unzipper_test_new_node(
    graph,
    layer0,
    alternating_layer_unzipper_test_node_type("NORMAL"),
  )
  let node2 = alternating_layer_unzipper_test_new_node(
    graph,
    layer0,
    alternating_layer_unzipper_test_node_type("NORMAL"),
  )
  let node3 = alternating_layer_unzipper_test_new_node(
    graph,
    layer0,
    alternating_layer_unzipper_test_node_type("NORMAL"),
  )
  let node4 = alternating_layer_unzipper_test_new_node(
    graph,
    layer0,
    alternating_layer_unzipper_test_node_type("NORMAL"),
  )
  let node21 = alternating_layer_unzipper_test_new_node(
    graph,
    layer1,
    alternating_layer_unzipper_test_node_type("NORMAL"),
  )
  let node22 = alternating_layer_unzipper_test_new_node(
    graph,
    layer1,
    alternating_layer_unzipper_test_node_type("NORMAL"),
  )
  let node23 = alternating_layer_unzipper_test_new_node(
    graph,
    layer1,
    alternating_layer_unzipper_test_node_type("NORMAL"),
  )

  ignore(alternating_layer_unzipper_test_new_edge(node1, node21))
  ignore(alternating_layer_unzipper_test_new_edge(node2, node21))
  ignore(alternating_layer_unzipper_test_new_edge(node2, node22))
  ignore(alternating_layer_unzipper_test_new_edge(node3, node21))
  ignore(alternating_layer_unzipper_test_new_edge(node3, node22))
  ignore(alternating_layer_unzipper_test_new_edge(node4, node22))
  ignore(alternating_layer_unzipper_test_new_edge(node4, node23))

  node1.set_property_int(layered_options_layer_unzipping_layer_split, 3)
  node21.set_property_int(layered_options_layer_unzipping_layer_split, 2)

  let processor = new_alternating_layer_unzipper_layout_processor()
  processor.process(graph, None)

  assert_true(
    alternating_layer_unzipper_test_layer_index(node1) <
    alternating_layer_unzipper_test_layer_index(node2),
  )
  assert_true(
    alternating_layer_unzipper_test_layer_index(node2) <
    alternating_layer_unzipper_test_layer_index(node3),
  )
  assert_true(
    alternating_layer_unzipper_test_layer_index(node4) <
    alternating_layer_unzipper_test_layer_index(node2),
  )
  assert_true(
    alternating_layer_unzipper_test_layer_index(node3) <
    alternating_layer_unzipper_test_layer_index(node21),
  )
  assert_true(
    alternating_layer_unzipper_test_layer_index(node3) <
    alternating_layer_unzipper_test_layer_index(node23),
  )
  assert_true(
    alternating_layer_unzipper_test_layer_index(node21) <
    alternating_layer_unzipper_test_layer_index(node22),
  )
  assert_true(
    alternating_layer_unzipper_test_layer_index(node23) <
    alternating_layer_unzipper_test_layer_index(node22),
  )
  alternating_layer_unzipper_test_assert_no_placeholders(graph)
}

///|
test "alternating layer unzipper resets alternation at long-edge nodes when enabled" {
  let graph = new_l_graph()
  let layer = new_layer(graph)
  graph.get_layers().push(layer)

  let a = alternating_layer_unzipper_test_new_node(
    graph,
    layer,
    alternating_layer_unzipper_test_node_type("NORMAL"),
  )
  let long_dummy = alternating_layer_unzipper_test_new_node(
    graph,
    layer,
    alternating_layer_unzipper_test_node_type("LONG_EDGE"),
  )
  let b = alternating_layer_unzipper_test_new_node(
    graph,
    layer,
    alternating_layer_unzipper_test_node_type("NORMAL"),
  )
  let c = alternating_layer_unzipper_test_new_node(
    graph,
    layer,
    alternating_layer_unzipper_test_node_type("NORMAL"),
  )
  let d = alternating_layer_unzipper_test_new_node(
    graph,
    layer,
    alternating_layer_unzipper_test_node_type("NORMAL"),
  )

  a.set_property_int(layered_options_layer_unzipping_layer_split, 3)
  a.set_property_bool(layered_options_layer_unzipping_reset_on_long_edges, true)

  let processor = new_alternating_layer_unzipper_layout_processor()
  processor.process(graph, None)

  assert_eq(alternating_layer_unzipper_test_require_layer(a).get_index(), 0)
  assert_eq(
    alternating_layer_unzipper_test_require_layer(long_dummy).get_index(),
    1,
  )
  assert_eq(alternating_layer_unzipper_test_require_layer(b).get_index(), 0)
  assert_eq(alternating_layer_unzipper_test_require_layer(c).get_index(), 1)
  assert_eq(alternating_layer_unzipper_test_require_layer(d).get_index(), 2)
  alternating_layer_unzipper_test_assert_no_placeholders(graph)
}

///|
test "alternating layer unzipper keeps pure round-robin when reset_on_long_edges is false" {
  let graph = new_l_graph()
  let layer = new_layer(graph)
  graph.get_layers().push(layer)

  let a = alternating_layer_unzipper_test_new_node(
    graph,
    layer,
    alternating_layer_unzipper_test_node_type("NORMAL"),
  )
  let long_dummy = alternating_layer_unzipper_test_new_node(
    graph,
    layer,
    alternating_layer_unzipper_test_node_type("LONG_EDGE"),
  )
  let b = alternating_layer_unzipper_test_new_node(
    graph,
    layer,
    alternating_layer_unzipper_test_node_type("NORMAL"),
  )
  let c = alternating_layer_unzipper_test_new_node(
    graph,
    layer,
    alternating_layer_unzipper_test_node_type("NORMAL"),
  )
  let d = alternating_layer_unzipper_test_new_node(
    graph,
    layer,
    alternating_layer_unzipper_test_node_type("NORMAL"),
  )

  a.set_property_int(layered_options_layer_unzipping_layer_split, 3)
  a.set_property_bool(
    layered_options_layer_unzipping_reset_on_long_edges, false,
  )

  let processor = new_alternating_layer_unzipper_layout_processor()
  processor.process(graph, None)

  assert_eq(alternating_layer_unzipper_test_require_layer(a).get_index(), 0)
  assert_eq(
    alternating_layer_unzipper_test_require_layer(long_dummy).get_index(),
    1,
  )
  assert_eq(alternating_layer_unzipper_test_require_layer(b).get_index(), 2)
  assert_eq(alternating_layer_unzipper_test_require_layer(c).get_index(), 0)
  assert_eq(alternating_layer_unzipper_test_require_layer(d).get_index(), 1)
  alternating_layer_unzipper_test_assert_no_placeholders(graph)
}

///|
test "intermediate strategy factory exposes alternating layer unzipper" {
  let factory = layered_intermediate_processor_factory(
    alternating_layer_unzipper_test_strategy("ALTERNATING_LAYER_UNZIPPER"),
  )
  assert_eq(factory.factory_id(), 23026)
  assert_eq(factory.factory_order(), 26)
}
