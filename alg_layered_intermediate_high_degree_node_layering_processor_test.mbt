///|
fn high_degree_test_strategy(name : String) -> IntermediateProcessorStrategy {
  for strategy in intermediate_processor_strategy_values() {
    if intermediate_processor_strategy_to_string(strategy) == name {
      return strategy
    }
  }
  abort("unknown intermediate processor strategy")
}

///|
fn high_degree_test_new_layer(graph : LGraph) -> Layer {
  let layer = new_layer(graph)
  graph.get_layers().push(layer)
  layer
}

///|
fn high_degree_test_new_node(graph : LGraph, layer : Layer, id : Int) -> LNode {
  let node = new_l_node(graph=Some(graph))
  node.set_id(id)
  node.set_layer(Some(layer))
  node
}

///|
fn high_degree_test_port_side(name : String) -> PortSide {
  for side in port_side_values() {
    if port_side_to_string(side) == name {
      return side
    }
  }
  abort("unknown port side")
}

///|
fn high_degree_test_connect(source : LNode, target : LNode) -> LEdge {
  let source_port = new_l_port()
  source_port.set_side(high_degree_test_port_side("EAST"))
  source_port.set_node(Some(source))

  let target_port = new_l_port()
  target_port.set_side(high_degree_test_port_side("WEST"))
  target_port.set_node(Some(target))

  let edge = new_l_edge()
  edge.set_source(Some(source_port))
  edge.set_target(Some(target_port))
  edge
}

///|
fn high_degree_test_layer_index(node : LNode) -> Int {
  match node.get_layer() {
    Some(layer) => layer.get_index()
    None => abort("node has no layer")
  }
}

///|
test "high degree processor strategy factory uses Java ordinal id" {
  let strategy = high_degree_test_strategy("HIGH_DEGREE_NODE_LAYER_PROCESSOR")
  let factory = layered_intermediate_processor_factory(strategy)
  assert_eq(factory.factory_order(), 9)
  assert_eq(factory.factory_id(), 23009)
}

///|
test "high degree processor moves short trees to inserted layers around high degree node" {
  let graph = new_l_graph()
  let layer0 = high_degree_test_new_layer(graph)
  let layer1 = high_degree_test_new_layer(graph)
  let layer2 = high_degree_test_new_layer(graph)
  let layer3 = high_degree_test_new_layer(graph)

  let x0 = high_degree_test_new_node(graph, layer0, 1)
  let x1 = high_degree_test_new_node(graph, layer1, 2)
  ignore(x0)
  ignore(x1)

  let c = high_degree_test_new_node(graph, layer0, 3)
  let r = high_degree_test_new_node(graph, layer1, 4)
  let s = high_degree_test_new_node(graph, layer1, 5)
  let h = high_degree_test_new_node(graph, layer2, 6)
  let t = high_degree_test_new_node(graph, layer3, 7)

  ignore(high_degree_test_connect(c, r))
  ignore(high_degree_test_connect(r, h))
  ignore(high_degree_test_connect(s, h))
  ignore(high_degree_test_connect(h, t))

  graph.set_property_int(layered_options_high_degree_nodes_threshold, 3)
  graph.set_property_int(layered_options_high_degree_nodes_tree_height, 5)

  let processor = new_high_degree_node_layering_processor_layout_processor()
  processor.process(graph, None)

  assert_eq(graph.get_layers().length(), 6)

  let high_layer = high_degree_test_layer_index(h)
  assert_eq(high_degree_test_layer_index(r), high_layer - 1)
  assert_eq(high_degree_test_layer_index(s), high_layer - 1)
  assert_eq(high_degree_test_layer_index(c), high_layer - 2)
  assert_eq(high_degree_test_layer_index(t), high_layer + 1)

  assert_eq(high_degree_test_layer_index(x0), 0)
  assert_eq(high_degree_test_layer_index(x1), 1)
}
