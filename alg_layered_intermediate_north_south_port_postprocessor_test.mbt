///|
fn north_south_port_postprocessor_test_strategy(
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
fn north_south_port_postprocessor_test_port_side(name : String) -> PortSide {
  for side in port_side_values() {
    if port_side_to_string(side) == name {
      return side
    }
  }
  abort("unknown port side")
}

///|
fn north_south_port_postprocessor_test_node_type(name : String) -> NodeType {
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
fn north_south_port_postprocessor_test_require_source(edge : LEdge) -> LPort {
  match edge.get_source() {
    Some(value) => value
    None => abort("edge has no source")
  }
}

///|
fn north_south_port_postprocessor_test_require_target(edge : LEdge) -> LPort {
  match edge.get_target() {
    Some(value) => value
    None => abort("edge has no target")
  }
}

///|
fn north_south_port_postprocessor_test_contains_node(
  layer : Layer,
  node : LNode,
) -> Bool {
  for candidate in layer.get_nodes() {
    if candidate.get_handle() == node.get_handle() {
      return true
    }
  }
  false
}

///|
test "north south port postprocessor reports expected task name" {
  let processor = new_north_south_port_postprocessor_layout_processor()
  let monitor = new_elk_progress_monitor()
  processor.process(new_l_graph(), Some(monitor))
  inspect(monitor.get_task_name(), content="Odd port side processing")
}

///|
test "north south port postprocessor reconnects non-spline dummy and adds bend/junction points" {
  let graph = new_l_graph()
  graph.set_property_string(edge_routing, "ORTHOGONAL")

  let layer = new_layer(graph)
  graph.get_layers().push(layer)

  let origin_node = new_l_node(graph=Some(graph))
  origin_node.set_layer(Some(layer))
  ignore(origin_node.get_position().set_xy(100.0, 0.0))
  let origin_port = new_l_port()
  origin_port.set_side(north_south_port_postprocessor_test_port_side("NORTH"))
  origin_port.set_node(Some(origin_node))
  ignore(origin_port.get_position().set_xy(20.0, 0.0))

  let source_node = new_l_node(graph=Some(graph))
  source_node.set_layer(Some(layer))
  let source_port = new_l_port()
  source_port.set_side(north_south_port_postprocessor_test_port_side("EAST"))
  source_port.set_node(Some(source_node))

  let target_node = new_l_node(graph=Some(graph))
  target_node.set_layer(Some(layer))
  let target_port = new_l_port()
  target_port.set_side(north_south_port_postprocessor_test_port_side("WEST"))
  target_port.set_node(Some(target_node))

  let dummy = new_l_node(graph=Some(graph))
  dummy.set_type(
    north_south_port_postprocessor_test_node_type("NORTH_SOUTH_PORT"),
  )
  dummy.set_layer(Some(layer))
  ignore(dummy.get_position().set_xy(0.0, 70.0))

  let dummy_in = new_l_port()
  dummy_in.set_side(north_south_port_postprocessor_test_port_side("WEST"))
  dummy_in.set_node(Some(dummy))
  dummy_in.set_property_l_port(
    internal_properties_origin_l_port,
    Some(origin_port),
  )

  let dummy_out = new_l_port()
  dummy_out.set_side(north_south_port_postprocessor_test_port_side("EAST"))
  dummy_out.set_node(Some(dummy))
  dummy_out.set_property_l_port(
    internal_properties_origin_l_port,
    Some(origin_port),
  )

  let in_edge = new_l_edge()
  in_edge.set_source(Some(source_port))
  in_edge.set_target(Some(dummy_in))

  let out_edge = new_l_edge()
  out_edge.set_source(Some(dummy_out))
  out_edge.set_target(Some(target_port))

  let processor = new_north_south_port_postprocessor_layout_processor()
  processor.process(graph, None)

  let bend_x = origin_port.get_absolute_anchor().x
  let bend_y = dummy.get_position().y

  assert_eq(
    north_south_port_postprocessor_test_require_target(in_edge).get_handle(),
    origin_port.get_handle(),
  )
  assert_eq(in_edge.get_bend_points().size(), 1)
  assert_eq(in_edge.get_bend_points().get(0).x, bend_x)
  assert_eq(in_edge.get_bend_points().get(0).y, bend_y)
  assert_true(
    in_edge.has_property_kvector_chain(layered_options_junction_points),
  )
  let in_junctions = in_edge.get_property_kvector_chain(
    layered_options_junction_points,
  )
  assert_eq(in_junctions.size(), 1)
  assert_eq(in_junctions.get(0).x, bend_x)
  assert_eq(in_junctions.get(0).y, bend_y)

  assert_eq(
    north_south_port_postprocessor_test_require_source(out_edge).get_handle(),
    origin_port.get_handle(),
  )
  assert_eq(out_edge.get_bend_points().size(), 1)
  assert_eq(out_edge.get_bend_points().get(0).x, bend_x)
  assert_eq(out_edge.get_bend_points().get(0).y, bend_y)
  assert_true(
    out_edge.has_property_kvector_chain(layered_options_junction_points),
  )
  let out_junctions = out_edge.get_property_kvector_chain(
    layered_options_junction_points,
  )
  assert_eq(out_junctions.size(), 1)
  assert_eq(out_junctions.get(0).x, bend_x)
  assert_eq(out_junctions.get(0).y, bend_y)

  assert_false(north_south_port_postprocessor_test_contains_node(layer, dummy))
}

///|
test "north south port postprocessor handles self-loop dummy reconnect" {
  let graph = new_l_graph()
  graph.set_property_string(edge_routing, "ORTHOGONAL")

  let layer = new_layer(graph)
  graph.get_layers().push(layer)

  let regular_node = new_l_node(graph=Some(graph))
  regular_node.set_layer(Some(layer))
  ignore(regular_node.get_position().set_xy(100.0, 0.0))

  let origin_in = new_l_port()
  origin_in.set_side(north_south_port_postprocessor_test_port_side("NORTH"))
  origin_in.set_node(Some(regular_node))
  ignore(origin_in.get_position().set_xy(10.0, 0.0))

  let origin_out = new_l_port()
  origin_out.set_side(north_south_port_postprocessor_test_port_side("SOUTH"))
  origin_out.set_node(Some(regular_node))
  ignore(origin_out.get_position().set_xy(40.0, 20.0))

  let dummy = new_l_node(graph=Some(graph))
  dummy.set_type(
    north_south_port_postprocessor_test_node_type("NORTH_SOUTH_PORT"),
  )
  dummy.set_layer(Some(layer))
  ignore(dummy.get_position().set_xy(0.0, 60.0))

  let dummy_in = new_l_port()
  dummy_in.set_side(north_south_port_postprocessor_test_port_side("WEST"))
  dummy_in.set_node(Some(dummy))
  dummy_in.set_property_l_port(
    internal_properties_origin_l_port,
    Some(origin_in),
  )

  let dummy_out = new_l_port()
  dummy_out.set_side(north_south_port_postprocessor_test_port_side("EAST"))
  dummy_out.set_node(Some(dummy))
  dummy_out.set_property_l_port(
    internal_properties_origin_l_port,
    Some(origin_out),
  )

  let self_loop = new_l_edge()
  self_loop.set_source(Some(dummy_out))
  self_loop.set_target(Some(dummy_in))

  dummy.set_property_l_edge(internal_properties_origin_l_edge, Some(self_loop))

  let processor = new_north_south_port_postprocessor_layout_processor()
  processor.process(graph, None)

  assert_eq(
    north_south_port_postprocessor_test_require_source(self_loop).get_handle(),
    origin_out.get_handle(),
  )
  assert_eq(
    north_south_port_postprocessor_test_require_target(self_loop).get_handle(),
    origin_in.get_handle(),
  )
  assert_eq(self_loop.get_bend_points().size(), 2)
  assert_eq(
    self_loop.get_bend_points().get(0).x,
    origin_out.get_absolute_anchor().x,
  )
  assert_eq(
    self_loop.get_bend_points().get(1).x,
    origin_in.get_absolute_anchor().x,
  )
  assert_false(north_south_port_postprocessor_test_contains_node(layer, dummy))
}

///|
test "north south port postprocessor reroutes spline dummy without bend points" {
  let graph = new_l_graph()
  graph.set_property_string(edge_routing, "SPLINES")

  let layer = new_layer(graph)
  graph.get_layers().push(layer)

  let origin_node = new_l_node(graph=Some(graph))
  origin_node.set_layer(Some(layer))
  let origin_in = new_l_port()
  origin_in.set_side(north_south_port_postprocessor_test_port_side("NORTH"))
  origin_in.set_node(Some(origin_node))
  let origin_out = new_l_port()
  origin_out.set_side(north_south_port_postprocessor_test_port_side("SOUTH"))
  origin_out.set_node(Some(origin_node))

  let source_node = new_l_node(graph=Some(graph))
  source_node.set_layer(Some(layer))
  let source_port = new_l_port()
  source_port.set_side(north_south_port_postprocessor_test_port_side("EAST"))
  source_port.set_node(Some(source_node))

  let target_node = new_l_node(graph=Some(graph))
  target_node.set_layer(Some(layer))
  let target_port = new_l_port()
  target_port.set_side(north_south_port_postprocessor_test_port_side("WEST"))
  target_port.set_node(Some(target_node))

  let dummy = new_l_node(graph=Some(graph))
  dummy.set_type(
    north_south_port_postprocessor_test_node_type("NORTH_SOUTH_PORT"),
  )
  dummy.set_layer(Some(layer))
  ignore(dummy.get_position().set_xy(0.0, 33.0))

  let dummy_in = new_l_port()
  dummy_in.set_side(north_south_port_postprocessor_test_port_side("WEST"))
  dummy_in.set_node(Some(dummy))
  dummy_in.set_property_l_port(
    internal_properties_origin_l_port,
    Some(origin_in),
  )

  let dummy_out = new_l_port()
  dummy_out.set_side(north_south_port_postprocessor_test_port_side("EAST"))
  dummy_out.set_node(Some(dummy))
  dummy_out.set_property_l_port(
    internal_properties_origin_l_port,
    Some(origin_out),
  )

  let in_edge = new_l_edge()
  in_edge.set_source(Some(source_port))
  in_edge.set_target(Some(dummy_in))

  let out_edge = new_l_edge()
  out_edge.set_source(Some(dummy_out))
  out_edge.set_target(Some(target_port))

  let processor = new_north_south_port_postprocessor_layout_processor()
  processor.process(graph, None)

  assert_eq(
    north_south_port_postprocessor_test_require_target(in_edge).get_handle(),
    origin_in.get_handle(),
  )
  assert_eq(
    north_south_port_postprocessor_test_require_source(out_edge).get_handle(),
    origin_out.get_handle(),
  )
  assert_eq(in_edge.get_bend_points().size(), 0)
  assert_eq(out_edge.get_bend_points().size(), 0)
  assert_eq(
    origin_in.get_property_double(internal_properties_spline_ns_port_y_coord),
    33.0,
  )
  assert_eq(
    origin_out.get_property_double(internal_properties_spline_ns_port_y_coord),
    33.0,
  )
  assert_false(north_south_port_postprocessor_test_contains_node(layer, dummy))
}

///|
test "north south port postprocessor strategy creates concrete processor" {
  let factory = layered_intermediate_processor_factory(
    north_south_port_postprocessor_test_strategy(
      "NORTH_SOUTH_PORT_POSTPROCESSOR",
    ),
  )
  let processor = factory.create()
  let monitor = new_elk_progress_monitor()
  processor.process(new_l_graph(), Some(monitor))
  inspect(monitor.get_task_name(), content="Odd port side processing")
}
