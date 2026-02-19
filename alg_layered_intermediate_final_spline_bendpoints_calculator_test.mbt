///|
fn final_spline_test_strategy(name : String) -> IntermediateProcessorStrategy {
  for strategy in intermediate_processor_strategy_values() {
    if intermediate_processor_strategy_to_string(strategy) == name {
      return strategy
    }
  }
  abort("unknown intermediate processor strategy")
}

///|
fn final_spline_test_port_side(name : String) -> PortSide {
  for side in port_side_values() {
    if port_side_to_string(side) == name {
      return side
    }
  }
  abort("unknown port side")
}

///|
fn final_spline_test_spline_mode(name : String) -> SplineRoutingMode {
  for mode in spline_routing_mode_values() {
    if spline_routing_mode_to_string(mode) == name {
      return mode
    }
  }
  abort("unknown spline routing mode")
}

///|
fn final_spline_test_side(name : String) -> SplineSideToProcess {
  for side in spline_side_to_process_values() {
    if spline_side_to_process_to_string(side) == name {
      return side
    }
  }
  abort("unknown spline side")
}

///|
fn final_spline_test_new_layer(graph : LGraph) -> Layer {
  let layer = new_layer(graph)
  graph.get_layers().push(layer)
  layer
}

///|
fn final_spline_test_new_node(
  graph : LGraph,
  layer : Layer,
  id : Int,
  x : Double,
  y : Double,
) -> LNode {
  let node = new_l_node(graph=Some(graph))
  node.set_id(id)
  node.set_layer(Some(layer))
  ignore(node.get_position().set_xy(x, y))
  ignore(node.get_size().set_xy(10.0, 10.0))
  node
}

///|
fn final_spline_test_connect(
  source : LNode,
  target : LNode,
) -> (LEdge, LPort, LPort) {
  let source_port = new_l_port()
  source_port.set_side(final_spline_test_port_side("EAST"))
  source_port.set_node(Some(source))
  ignore(source_port.get_position().set_xy(10.0, 5.0))

  let target_port = new_l_port()
  target_port.set_side(final_spline_test_port_side("WEST"))
  target_port.set_node(Some(target))
  ignore(target_port.get_position().set_xy(0.0, 5.0))

  let edge = new_l_edge()
  edge.set_source(Some(source_port))
  edge.set_target(Some(target_port))
  (edge, source_port, target_port)
}

///|
fn final_spline_test_build_graph() -> (LGraph, LEdge) {
  let graph = new_l_graph()
  let layer0 = final_spline_test_new_layer(graph)
  let layer1 = final_spline_test_new_layer(graph)

  let source = final_spline_test_new_node(graph, layer0, 1, 0.0, 0.0)
  let target = final_spline_test_new_node(graph, layer1, 2, 80.0, 0.0)
  let (edge, _, _) = final_spline_test_connect(source, target)

  let segment = new_spline_segment_single_edge(
    edge,
    final_spline_test_side("LEFT"),
    final_spline_test_side("RIGHT"),
  )

  edge.set_property_spline_segment_array(
    internal_properties_spline_route_start,
    [segment],
  )
  edge.set_property_l_edge_array(internal_properties_spline_edge_chain, [edge])

  graph.set_property_double(
    layered_options_spacing_edge_edge_between_layers, 10.0,
  )
  graph.set_property_double(
    layered_options_spacing_edge_node_between_layers, 10.0,
  )
  graph.set_property_spline_routing_mode(
    layered_options_edge_routing_splines_mode,
    final_spline_test_spline_mode("CONSERVATIVE"),
  )
  graph.set_property_string(
    layered_options_compaction_post_compaction_strategy, "NONE",
  )

  (graph, edge)
}

///|
test "final spline processor strategy factory uses Java ordinal id" {
  let strategy = final_spline_test_strategy(
    "FINAL_SPLINE_BENDPOINTS_CALCULATOR",
  )
  let factory = layered_intermediate_processor_factory(strategy)
  assert_eq(factory.factory_order(), 52)
  assert_eq(factory.factory_id(), 23052)
}

///|
test "final spline processor creates bend points from stored spline segments and clears working properties" {
  let (graph, edge) = final_spline_test_build_graph()
  assert_true(edge.get_bend_points().is_empty())

  let processor = new_final_spline_bendpoints_calculator_layout_processor()
  processor.process(graph, None)

  assert_false(edge.get_bend_points().is_empty())
  assert_true(
    edge
    .get_property_spline_segment_array(internal_properties_spline_route_start)
    .is_empty(),
  )
  assert_true(
    edge
    .get_property_l_edge_array(internal_properties_spline_edge_chain)
    .is_empty(),
  )
}
