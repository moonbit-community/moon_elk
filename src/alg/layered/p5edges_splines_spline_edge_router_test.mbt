///|
fn spline_edge_router_test_node_type(name : String) -> NodeType {
  let types = node_type_values()
  for t in types {
    match t {
      NodeType::Normal => if name == "NORMAL" { return t }
      NodeType::LongEdge => if name == "LONG_EDGE" { return t }
      NodeType::ExternalPort => if name == "EXTERNAL_PORT" { return t }
      NodeType::NorthSouthPort => if name == "NORTH_SOUTH_PORT" { return t }
      NodeType::LabelNode => if name == "LABEL" { return t }
      NodeType::BreakingPoint => if name == "BREAKING_POINT" { return t }
      NodeType::Placeholder => if name == "PLACEHOLDER" { return t }
      NodeType::NonshiftingPlaceholder =>
        if name == "NONSHIFTING_PLACEHOLDER" {
          return t
        }
    }
  }
  abort("unknown node type")
}

///|
fn spline_edge_router_test_graph_property(name : String) -> GraphProperties {
  for property in graph_properties_values() {
    if graph_properties_to_string(property) == name {
      return property
    }
  }
  abort("unknown graph property")
}

///|
fn spline_edge_router_test_port_side(name : String) -> @core.PortSide {
  for side in @core.port_side_values() {
    if @core.port_side_to_string(side) == name {
      return side
    }
  }
  abort("unknown port side")
}

///|
fn spline_edge_router_test_spline_routing_mode(
  name : String,
) -> SplineRoutingMode {
  for mode in spline_routing_mode_values() {
    if spline_routing_mode_to_string(mode) == name {
      return mode
    }
  }
  abort("unknown spline routing mode")
}

///|
fn spline_edge_router_test_strategy(
  name : String,
) -> IntermediateProcessorStrategy {
  for strategy in intermediate_processor_strategy_values() {
    if intermediate_processor_strategy_to_string(strategy) == name {
      return strategy
    }
  }
  abort("unknown intermediate strategy")
}

///|
fn spline_edge_router_test_contains_factory(
  factories : Array[@core.ILayoutProcessorFactory[LayeredPhases, LGraph]],
  strategy : IntermediateProcessorStrategy,
) -> Bool {
  let expected_id = layered_intermediate_processor_factory(strategy).factory_id()
  for factory in factories {
    if factory.factory_id() == expected_id {
      return true
    }
  }
  false
}

///|
fn spline_edge_router_test_build_two_layer_graph(
  mode : SplineRoutingMode,
  sloppy_factor : Double,
) -> (LGraph, LNode, LNode, LEdge) {
  let graph = new_l_graph()
  graph.set_property_double(
    layered_options_spacing_edge_node_between_layers, 10.0,
  )
  graph.set_property_double(
    layered_options_spacing_edge_edge_between_layers, 10.0,
  )
  graph.set_property_double(
    layered_options_spacing_node_node_between_layers, 20.0,
  )
  graph.set_property_spline_routing_mode(
    layered_options_edge_routing_splines_mode, mode,
  )
  graph.set_property_double(
    layered_options_edge_routing_splines_sloppy_layer_spacing_factor, sloppy_factor,
  )

  let left_layer = new_layer(graph)
  let right_layer = new_layer(graph)
  let left_layer_size = left_layer.get_size()
  ignore(left_layer_size.set_xy(30.0, left_layer_size.y))
  let right_layer_size = right_layer.get_size()
  ignore(right_layer_size.set_xy(40.0, right_layer_size.y))
  graph.get_layers().push(left_layer)
  graph.get_layers().push(right_layer)

  let left_node = new_l_node()
  left_node.set_layer(Some(left_layer))
  let left_node_size = left_node.get_size()
  ignore(left_node_size.set_xy(30.0, left_node_size.y))
  let left_node_position = left_node.get_position()
  ignore(left_node_position.set_xy(left_node_position.x, 0.0))

  let right_node = new_l_node()
  right_node.set_layer(Some(right_layer))
  let right_node_size = right_node.get_size()
  ignore(right_node_size.set_xy(40.0, right_node_size.y))
  let right_node_position = right_node.get_position()
  ignore(right_node_position.set_xy(right_node_position.x, 50.0))

  let left_port = new_l_port()
  left_port.set_side(spline_edge_router_test_port_side("EAST"))
  left_port.set_node(Some(left_node))

  let right_port = new_l_port()
  right_port.set_side(spline_edge_router_test_port_side("WEST"))
  right_port.set_node(Some(right_node))

  let edge = new_l_edge()
  edge.set_source(Some(left_port))
  edge.set_target(Some(right_port))

  (graph, left_node, right_node, edge)
}

///|
test "spline edge router straight threshold" {
  assert_true(spline_edge_router_is_straight(1.0, 1.19))
  assert_false(spline_edge_router_is_straight(1.0, 1.21))
}

///|
test "spline edge router node classifiers" {
  let normal = new_l_node()
  normal.set_type(spline_edge_router_test_node_type("NORMAL"))

  let breaking = new_l_node()
  breaking.set_type(spline_edge_router_test_node_type("BREAKING_POINT"))

  let long_edge = new_l_node()
  long_edge.set_type(spline_edge_router_test_node_type("LONG_EDGE"))

  let ext = new_l_node()
  ext.set_type(spline_edge_router_test_node_type("EXTERNAL_PORT"))

  let north_south = new_l_node()
  north_south.set_type(spline_edge_router_test_node_type("NORTH_SOUTH_PORT"))

  assert_true(spline_edge_router_is_normal_node(normal))
  assert_true(spline_edge_router_is_normal_node(breaking))
  assert_false(spline_edge_router_is_normal_node(long_edge))

  assert_true(spline_edge_router_is_qualified_as_starting_node(normal))
  assert_true(spline_edge_router_is_qualified_as_starting_node(breaking))
  assert_true(spline_edge_router_is_qualified_as_starting_node(ext))
  assert_true(spline_edge_router_is_qualified_as_starting_node(north_south))
  assert_false(spline_edge_router_is_qualified_as_starting_node(long_edge))
}

///|
test "spline edge router layout phase starts monitor with expected task" {
  let phase = new_spline_edge_router_layout_phase()
  assert_true(phase.is_layout_phase())

  let monitor = new_elk_progress_monitor()
  phase.process(new_l_graph(), Some(monitor))
  inspect(monitor.get_task_name(), content="Spline edge routing")
}

///|
test "spline edge router process sets width to zero for empty layered graph" {
  let phase = new_spline_edge_router_layout_phase()
  let graph = new_l_graph()
  graph.set_size_xy(123.0, graph.get_size().y)

  phase.process(graph, None)
  assert_eq(graph.get_size().x, 0.0)
}

///|
test "spline edge router process routes two-layer graph and stores edge chain" {
  let phase = new_spline_edge_router_layout_phase()
  let (graph, left_node, right_node, edge) = spline_edge_router_test_build_two_layer_graph(
    spline_edge_router_test_spline_routing_mode("CONSERVATIVE"),
    1.0,
  )

  phase.process(graph, None)

  assert_eq(left_node.get_position().x, 0.0)
  assert_eq(right_node.get_position().x, 50.0)
  assert_eq(graph.get_size().x, 90.0)

  let chain = edge.get_property_l_edge_array(
    internal_properties_spline_edge_chain,
  )
  assert_eq(chain.length(), 1)
  assert_eq(chain[0].get_handle(), edge.get_handle())

  let spline_route = edge.get_property_spline_segment_array(
    internal_properties_spline_route_start,
  )
  assert_eq(spline_route.length(), 1)
  assert_true(spline_route[0].initial_segment)
  assert_true(spline_route[0].last_segment)
}

///|
test "spline edge router process uses sloppy mode spacing factor" {
  let phase = new_spline_edge_router_layout_phase()
  let (graph, _, right_node, _) = spline_edge_router_test_build_two_layer_graph(
    spline_edge_router_test_spline_routing_mode("SLOPPY"),
    1.0,
  )

  phase.process(graph, None)

  assert_eq(right_node.get_position().x, 55.0)
  assert_eq(graph.get_size().x, 95.0)
}

///|
test "spline edge router configuration includes baseline processor dependencies" {
  let phase = new_spline_edge_router_layout_phase()
  let graph = new_l_graph()
  let configuration = match phase.get_layout_processor_configuration(graph) {
    Some(value) => value
    None => abort("spline edge router configuration must exist")
  }
  let phases = layered_phase_constants()
  let p3_node_ordering = phases[2]
  let p5_edge_routing = phases[4]

  assert_true(
    spline_edge_router_test_contains_factory(
      configuration.processors_before(p3_node_ordering),
      spline_edge_router_test_strategy("INVERTED_PORT_PROCESSOR"),
    ),
  )
  assert_true(
    spline_edge_router_test_contains_factory(
      configuration.processors_after(p5_edge_routing),
      spline_edge_router_test_strategy("FINAL_SPLINE_BENDPOINTS_CALCULATOR"),
    ),
  )
}

///|
test "spline edge router configuration adds optional processors by graph properties" {
  let phase = new_spline_edge_router_layout_phase()
  let graph = new_l_graph()
  graph.set_property_graph_properties_array(
    internal_properties_graph_properties,
    [
      spline_edge_router_test_graph_property("SELF_LOOPS"),
      spline_edge_router_test_graph_property("CENTER_LABELS"),
      spline_edge_router_test_graph_property("NORTH_SOUTH_PORTS"),
      spline_edge_router_test_graph_property("END_LABELS"),
    ],
  )

  let configuration = match phase.get_layout_processor_configuration(graph) {
    Some(value) => value
    None => abort("spline edge router configuration must exist")
  }
  let phases = layered_phase_constants()
  let p1_cycle_breaking = phases[0]
  let p2_layering = phases[1]
  let p3_node_ordering = phases[2]
  let p4_node_placement = phases[3]
  let p5_edge_routing = phases[4]

  assert_true(
    spline_edge_router_test_contains_factory(
      configuration.processors_before(p1_cycle_breaking),
      spline_edge_router_test_strategy("SELF_LOOP_PREPROCESSOR"),
    ),
  )
  assert_true(
    spline_edge_router_test_contains_factory(
      configuration.processors_before(p2_layering),
      spline_edge_router_test_strategy("LABEL_DUMMY_INSERTER"),
    ),
  )
  assert_true(
    spline_edge_router_test_contains_factory(
      configuration.processors_before(p3_node_ordering),
      spline_edge_router_test_strategy("NORTH_SOUTH_PORT_PREPROCESSOR"),
    ),
  )
  assert_true(
    spline_edge_router_test_contains_factory(
      configuration.processors_before(p4_node_placement),
      spline_edge_router_test_strategy("SELF_LOOP_PORT_RESTORER"),
    ),
  )
  assert_true(
    spline_edge_router_test_contains_factory(
      configuration.processors_before(p4_node_placement),
      spline_edge_router_test_strategy("SELF_LOOP_ROUTER"),
    ),
  )
  assert_true(
    spline_edge_router_test_contains_factory(
      configuration.processors_before(p4_node_placement),
      spline_edge_router_test_strategy("LABEL_DUMMY_SWITCHER"),
    ),
  )
  assert_true(
    spline_edge_router_test_contains_factory(
      configuration.processors_before(p4_node_placement),
      spline_edge_router_test_strategy("LABEL_SIDE_SELECTOR"),
    ),
  )
  assert_true(
    spline_edge_router_test_contains_factory(
      configuration.processors_before(p4_node_placement),
      spline_edge_router_test_strategy("END_LABEL_PREPROCESSOR"),
    ),
  )
  assert_true(
    spline_edge_router_test_contains_factory(
      configuration.processors_before(p5_edge_routing),
      spline_edge_router_test_strategy("NORTH_SOUTH_PORT_POSTPROCESSOR"),
    ),
  )
  assert_true(
    spline_edge_router_test_contains_factory(
      configuration.processors_after(p5_edge_routing),
      spline_edge_router_test_strategy("SELF_LOOP_POSTPROCESSOR"),
    ),
  )
  assert_true(
    spline_edge_router_test_contains_factory(
      configuration.processors_after(p5_edge_routing),
      spline_edge_router_test_strategy("LABEL_DUMMY_REMOVER"),
    ),
  )
  assert_true(
    spline_edge_router_test_contains_factory(
      configuration.processors_after(p5_edge_routing),
      spline_edge_router_test_strategy("END_LABEL_POSTPROCESSOR"),
    ),
  )
}
