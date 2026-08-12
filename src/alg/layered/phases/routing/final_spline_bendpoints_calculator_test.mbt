///|
fn final_spline_test_strategy(
  name : String,
) -> @runtime.IntermediateProcessorStrategy {
  for strategy in @runtime.intermediate_processor_strategy_values() {
    if @runtime.intermediate_processor_strategy_to_string(strategy) == name {
      return strategy
    }
  }
  abort("unknown intermediate processor strategy")
}

///|
fn final_spline_test_port_side(name : String) -> @core.PortSide {
  for side in @core.port_side_values() {
    if @core.port_side_to_string(side) == name {
      return side
    }
  }
  abort("unknown port side")
}

///|
fn final_spline_test_spline_mode(name : String) -> @options.SplineRoutingMode {
  for mode in @options.spline_routing_mode_values() {
    if @options.spline_routing_mode_to_string(mode) == name {
      return mode
    }
  }
  abort("unknown spline routing mode")
}

///|
fn final_spline_test_side(name : String) -> @runtime.SplineSideToProcess {
  for side in @runtime.spline_side_to_process_values() {
    if @runtime.spline_side_to_process_to_string(side) == name {
      return side
    }
  }
  abort("unknown spline side")
}

///|
fn final_spline_test_new_layer(graph : @runtime.LGraph) -> @runtime.Layer {
  let layer = @runtime.new_layer(graph)
  graph.get_layers().push(layer)
  layer
}

///|
fn final_spline_test_new_node(
  graph : @runtime.LGraph,
  layer : @runtime.Layer,
  id : Int,
  x : Double,
  y : Double,
) -> @runtime.LNode {
  let node = @runtime.new_l_node(graph=Some(graph))
  node.set_id(id)
  node.set_layer(Some(layer))
  ignore(node.get_position().set_xy(x, y))
  ignore(node.get_size().set_xy(10.0, 10.0))
  node
}

///|
fn final_spline_test_connect(
  source : @runtime.LNode,
  target : @runtime.LNode,
) -> (@runtime.LEdge, @runtime.LPort, @runtime.LPort) {
  let source_port = @runtime.new_l_port()
  source_port.set_side(final_spline_test_port_side("EAST"))
  source_port.set_node(Some(source))
  ignore(source_port.get_position().set_xy(10.0, 5.0))

  let target_port = @runtime.new_l_port()
  target_port.set_side(final_spline_test_port_side("WEST"))
  target_port.set_node(Some(target))
  ignore(target_port.get_position().set_xy(0.0, 5.0))

  let edge = @runtime.new_l_edge()
  edge.set_source(Some(source_port))
  edge.set_target(Some(target_port))
  (edge, source_port, target_port)
}

///|
fn final_spline_test_build_graph() -> (
  @runtime.LayeredRunState,
  @runtime.LGraph,
  @runtime.LEdge,
) raise {
  let state = @runtime.new_layered_run_state()
  let graph = @runtime.new_l_graph()
  let layer0 = final_spline_test_new_layer(graph)
  let layer1 = final_spline_test_new_layer(graph)

  let source = final_spline_test_new_node(graph, layer0, 1, 0.0, 0.0)
  let target = final_spline_test_new_node(graph, layer1, 2, 80.0, 0.0)
  let (edge, _, _) = final_spline_test_connect(source, target)

  let segment = @runtime.new_spline_segment_single_edge(
    edge,
    final_spline_test_side("LEFT"),
    final_spline_test_side("RIGHT"),
  )

  state.set_spline_segments(edge, [segment])
  edge.set_property_l_edge_array(
    @runtime.internal_properties_spline_edge_chain,
    [edge],
  )

  graph.set_property_double(
    @options.layered_options_spacing_edge_edge_between_layers, 10.0,
  )
  graph.set_property_double(
    @options.layered_options_spacing_edge_node_between_layers, 10.0,
  )
  graph.set_property_spline_routing_mode(
    @options.layered_options_edge_routing_splines_mode,
    final_spline_test_spline_mode("CONSERVATIVE"),
  )
  graph.set_property_string(
    @options.layered_options_compaction_post_compaction_strategy, "NONE",
  )

  (state, graph, edge)
}

///|
test "final spline processor strategy factory uses Java ordinal id" {
  let strategy = final_spline_test_strategy(
    "FINAL_SPLINE_BENDPOINTS_CALCULATOR",
  )
  let factory = layered_intermediate_processor_factory(
    @runtime.new_l_graph(),
    strategy,
  )
  assert_eq(factory.factory_order(), 52)
  assert_eq(factory.factory_id(), 23052)
}

///|
test "final spline processor creates bend points from stored spline segments and clears working properties" {
  let (state, graph, edge) = final_spline_test_build_graph()
  assert_true(edge.get_bend_points().is_empty())

  let processor = new_final_spline_bendpoints_calculator_layout_processor(
    state~,
  )
  processor.process(graph, None)

  assert_false(edge.get_bend_points().is_empty())
  assert_true(state.get_spline_segments(edge).is_empty())
  assert_true(
    edge
    .get_property_l_edge_array(@runtime.internal_properties_spline_edge_chain)
    .is_empty(),
  )
}
