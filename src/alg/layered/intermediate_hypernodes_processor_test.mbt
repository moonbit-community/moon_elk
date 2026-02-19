///|
fn hypernodes_processor_test_strategy(
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
fn hypernodes_processor_test_port_side(name : String) -> @core.PortSide {
  for side in @core.port_side_values() {
    if @core.port_side_to_string(side) == name {
      return side
    }
  }
  abort("unknown port side")
}

///|
fn hypernodes_processor_test_require_source(edge : LEdge) -> LPort {
  match edge.get_source() {
    Some(value) => value
    None => abort("edge has no source")
  }
}

///|
test "hypernodes processor reports expected task name" {
  let processor = new_hypernodes_processor_layout_processor()
  let monitor = new_elk_progress_monitor()
  processor.process(new_l_graph(), Some(monitor))
  inspect(monitor.get_task_name(), content="Hypernodes processing")
}

///|
test "hypernodes processor moves right hypernode to first join-point x and reroutes edges" {
  let graph = new_l_graph()
  graph.set_size_xy(200.0, 0.0)

  let layer0 = new_layer(graph)
  let layer1 = new_layer(graph)
  graph.get_layers().push(layer0)
  graph.get_layers().push(layer1)

  let hypernode = new_l_node(graph=Some(graph))
  hypernode.set_layer(Some(layer0))
  hypernode.set_property_bool(layered_options_hypernode, true)
  ignore(hypernode.get_size().set_xy(20.0, 20.0))
  ignore(hypernode.get_position().set_xy(10.0, 0.0))

  let right_port_1 = new_l_port()
  right_port_1.set_side(hypernodes_processor_test_port_side("EAST"))
  right_port_1.set_node(Some(hypernode))
  let right_port_2 = new_l_port()
  right_port_2.set_side(hypernodes_processor_test_port_side("EAST"))
  right_port_2.set_node(Some(hypernode))

  let target_node_1 = new_l_node(graph=Some(graph))
  target_node_1.set_layer(Some(layer1))
  let target_port_1 = new_l_port()
  target_port_1.set_side(hypernodes_processor_test_port_side("WEST"))
  target_port_1.set_node(Some(target_node_1))

  let target_node_2 = new_l_node(graph=Some(graph))
  target_node_2.set_layer(Some(layer1))
  let target_port_2 = new_l_port()
  target_port_2.set_side(hypernodes_processor_test_port_side("WEST"))
  target_port_2.set_node(Some(target_node_2))

  let edge_1 = new_l_edge()
  edge_1.set_source(Some(right_port_1))
  edge_1.set_target(Some(target_port_1))
  edge_1.get_bend_points().add_last_xy(120.0, 10.0)
  edge_1.get_bend_points().add_last_xy(140.0, 35.0)
  let edge_1_junctions = @core.new_kvector_chain()
  edge_1_junctions.add_last_xy(120.0, 10.0)
  edge_1_junctions.add_last_xy(160.0, 50.0)
  edge_1.set_property_kvector_chain(
    layered_options_junction_points, edge_1_junctions,
  )

  let edge_2 = new_l_edge()
  edge_2.set_source(Some(right_port_2))
  edge_2.set_target(Some(target_port_2))
  edge_2.get_bend_points().add_last_xy(120.0, 40.0)
  edge_2.get_bend_points().add_last_xy(140.0, 20.0)

  let processor = new_hypernodes_processor_layout_processor()
  processor.process(graph, None)

  assert_eq(hypernode.get_position().x, 110.0)

  let north_ports = hypernode.get_ports_by_side(
    hypernodes_processor_test_port_side("NORTH"),
  )
  let south_ports = hypernode.get_ports_by_side(
    hypernodes_processor_test_port_side("SOUTH"),
  )
  assert_eq(north_ports.length(), 1)
  assert_eq(south_ports.length(), 1)

  assert_eq(
    @core.port_side_to_string(
      hypernodes_processor_test_require_source(edge_1).get_side(),
    ),
    "SOUTH",
  )
  assert_eq(
    @core.port_side_to_string(
      hypernodes_processor_test_require_source(edge_2).get_side(),
    ),
    "NORTH",
  )

  assert_eq(edge_1.get_bend_points().size(), 1)
  assert_eq(edge_1.get_bend_points().get(0).x, 140.0)
  assert_eq(edge_2.get_bend_points().size(), 1)
  assert_eq(edge_2.get_bend_points().get(0).x, 140.0)

  let edge_1_junction_points = edge_1.get_property_kvector_chain(
    layered_options_junction_points,
  )
  assert_eq(edge_1_junction_points.size(), 1)
  assert_eq(edge_1_junction_points.get(0).x, 160.0)
}

///|
test "hypernodes processor keeps left-directed case unchanged (upstream parity)" {
  let graph = new_l_graph()
  graph.set_size_xy(200.0, 0.0)

  let layer0 = new_layer(graph)
  let layer1 = new_layer(graph)
  graph.get_layers().push(layer0)
  graph.get_layers().push(layer1)

  let source_node_1 = new_l_node(graph=Some(graph))
  source_node_1.set_layer(Some(layer0))
  let source_port_1 = new_l_port()
  source_port_1.set_side(hypernodes_processor_test_port_side("EAST"))
  source_port_1.set_node(Some(source_node_1))

  let source_node_2 = new_l_node(graph=Some(graph))
  source_node_2.set_layer(Some(layer0))
  let source_port_2 = new_l_port()
  source_port_2.set_side(hypernodes_processor_test_port_side("EAST"))
  source_port_2.set_node(Some(source_node_2))

  let hypernode = new_l_node(graph=Some(graph))
  hypernode.set_layer(Some(layer1))
  hypernode.set_property_bool(layered_options_hypernode, true)
  ignore(hypernode.get_size().set_xy(20.0, 20.0))
  ignore(hypernode.get_position().set_xy(70.0, 0.0))

  let left_port_1 = new_l_port()
  left_port_1.set_side(hypernodes_processor_test_port_side("WEST"))
  left_port_1.set_node(Some(hypernode))
  let left_port_2 = new_l_port()
  left_port_2.set_side(hypernodes_processor_test_port_side("WEST"))
  left_port_2.set_node(Some(hypernode))

  let edge_1 = new_l_edge()
  edge_1.set_source(Some(source_port_1))
  edge_1.set_target(Some(left_port_1))
  edge_1.get_bend_points().add_last_xy(60.0, 10.0)
  edge_1.get_bend_points().add_last_xy(50.0, 8.0)

  let edge_2 = new_l_edge()
  edge_2.set_source(Some(source_port_2))
  edge_2.set_target(Some(left_port_2))
  edge_2.get_bend_points().add_last_xy(60.0, 40.0)
  edge_2.get_bend_points().add_last_xy(50.0, 45.0)

  let processor = new_hypernodes_processor_layout_processor()
  processor.process(graph, None)

  assert_eq(hypernode.get_position().x, 70.0)
  assert_eq(
    hypernode
    .get_ports_by_side(hypernodes_processor_test_port_side("NORTH"))
    .length(),
    0,
  )
  assert_eq(
    hypernode
    .get_ports_by_side(hypernodes_processor_test_port_side("SOUTH"))
    .length(),
    0,
  )
  assert_eq(edge_1.get_bend_points().size(), 2)
  assert_eq(edge_2.get_bend_points().size(), 2)
}

///|
test "hypernodes processor strategy creates concrete processor" {
  let factory = layered_intermediate_processor_factory(
    hypernodes_processor_test_strategy("HYPERNODE_PROCESSOR"),
  )
  let processor = factory.create()
  let monitor = new_elk_progress_monitor()
  processor.process(new_l_graph(), Some(monitor))
  inspect(monitor.get_task_name(), content="Hypernodes processing")
}
