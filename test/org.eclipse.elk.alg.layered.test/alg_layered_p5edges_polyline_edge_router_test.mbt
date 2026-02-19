///|
fn polyline_edge_router_test_node_type(name : String) -> NodeType {
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
fn polyline_edge_router_test_graph_property(name : String) -> GraphProperties {
  for property in graph_properties_values() {
    if graph_properties_to_string(property) == name {
      return property
    }
  }
  abort("unknown graph property")
}

///|
fn polyline_edge_router_test_strategy(
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
fn polyline_edge_router_test_port_side(name : String) -> PortSide {
  for side in port_side_values() {
    if port_side_to_string(side) == name {
      return side
    }
  }
  abort("unknown port side")
}

///|
fn polyline_edge_router_test_contains_factory(
  factories : Array[ILayoutProcessorFactory[LayeredPhases, LGraph]],
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
fn polyline_edge_router_test_build_two_layer_graph() -> (
  LGraph,
  LNode,
  LNode,
  LEdge,
) {
  let graph = new_l_graph()
  graph.set_property_double(
    layered_options_spacing_edge_edge_between_layers, 10.0,
  )
  graph.set_property_double(
    layered_options_spacing_node_node_between_layers, 20.0,
  )
  graph.set_property_double(
    layered_options_edge_routing_polyline_sloped_edge_zone_width, 2.0,
  )

  let left_layer = new_layer(graph)
  let right_layer = new_layer(graph)
  graph.get_layers().push(left_layer)
  graph.get_layers().push(right_layer)

  ignore(left_layer.get_size().set_xy(30.0, left_layer.get_size().y))
  ignore(right_layer.get_size().set_xy(40.0, right_layer.get_size().y))

  let left_node = new_l_node()
  left_node.set_layer(Some(left_layer))
  ignore(left_node.get_size().set_xy(30.0, left_node.get_size().y))
  ignore(left_node.get_position().set_xy(left_node.get_position().x, 0.0))

  let right_node = new_l_node()
  right_node.set_layer(Some(right_layer))
  ignore(right_node.get_size().set_xy(40.0, right_node.get_size().y))
  ignore(right_node.get_position().set_xy(right_node.get_position().x, 50.0))

  let left_port = new_l_port()
  left_port.set_side(polyline_edge_router_test_port_side("EAST"))
  left_port.set_node(Some(left_node))

  let right_port = new_l_port()
  right_port.set_side(polyline_edge_router_test_port_side("WEST"))
  right_port.set_node(Some(right_node))

  let edge = new_l_edge()
  edge.set_source(Some(left_port))
  edge.set_target(Some(right_port))

  (graph, left_node, right_node, edge)
}

///|
test "polyline edge router predicate recognizes external west/east ports" {
  let node = new_l_node()
  node.set_type(polyline_edge_router_test_node_type("EXTERNAL_PORT"))
  node.set_property_port_side(
    internal_properties_ext_port_side,
    polyline_edge_router_test_port_side("WEST"),
  )
  assert_true(polyline_edge_router_is_external_west_or_east_port(node))
}

///|
test "polyline edge router layout phase starts monitor with expected task" {
  let phase = new_polyline_edge_router_layout_phase()
  assert_true(phase.is_layout_phase())

  let monitor = new_elk_progress_monitor()
  phase.process(new_l_graph(), Some(monitor))
  inspect(monitor.get_task_name(), content="Polyline edge routing")
}

///|
test "polyline edge router process sets width to zero for empty layered graph" {
  let phase = new_polyline_edge_router_layout_phase()
  let graph = new_l_graph()
  graph.set_size_xy(123.0, graph.get_size().y)

  phase.process(graph, None)
  assert_eq(graph.get_size().x, 0.0)
}

///|
test "polyline edge router process routes two-layer graph and sets width" {
  let phase = new_polyline_edge_router_layout_phase()
  let (graph, left_node, right_node, edge) = polyline_edge_router_test_build_two_layer_graph()

  phase.process(graph, None)

  assert_eq(left_node.get_position().x, 0.0)
  assert_eq(right_node.get_position().x, 60.0)
  assert_eq(graph.get_size().x, 100.0)

  let bends = edge.get_bend_points()
  assert_true(bends.size() >= 1)
  assert_eq(bends.get(0).x, 30.0)
  assert_eq(bends.get(0).y, 0.0)
}

///|
test "polyline edge router configuration baseline includes inverted port processor" {
  let phase = new_polyline_edge_router_layout_phase()
  let graph = new_l_graph()
  let configuration = match phase.get_layout_processor_configuration(graph) {
    Some(value) => value
    None => abort("polyline edge router configuration must exist")
  }
  let phases = layered_phase_constants()
  let p3_node_ordering = phases[2]

  assert_true(
    polyline_edge_router_test_contains_factory(
      configuration.processors_before(p3_node_ordering),
      polyline_edge_router_test_strategy("INVERTED_PORT_PROCESSOR"),
    ),
  )
}

///|
test "polyline edge router configuration adds optional processors by graph properties" {
  let phase = new_polyline_edge_router_layout_phase()
  let graph = new_l_graph()
  graph.set_property_graph_properties_array(
    internal_properties_graph_properties,
    [
      polyline_edge_router_test_graph_property("NORTH_SOUTH_PORTS"),
      polyline_edge_router_test_graph_property("SELF_LOOPS"),
      polyline_edge_router_test_graph_property("CENTER_LABELS"),
      polyline_edge_router_test_graph_property("END_LABELS"),
    ],
  )

  let configuration = match phase.get_layout_processor_configuration(graph) {
    Some(value) => value
    None => abort("polyline edge router configuration must exist")
  }
  let phases = layered_phase_constants()
  let p1_cycle_breaking = phases[0]
  let p2_layering = phases[1]
  let p3_node_ordering = phases[2]
  let p4_node_placement = phases[3]
  let p5_edge_routing = phases[4]

  assert_true(
    polyline_edge_router_test_contains_factory(
      configuration.processors_before(p1_cycle_breaking),
      polyline_edge_router_test_strategy("SELF_LOOP_PREPROCESSOR"),
    ),
  )
  assert_true(
    polyline_edge_router_test_contains_factory(
      configuration.processors_before(p2_layering),
      polyline_edge_router_test_strategy("LABEL_DUMMY_INSERTER"),
    ),
  )
  assert_true(
    polyline_edge_router_test_contains_factory(
      configuration.processors_before(p3_node_ordering),
      polyline_edge_router_test_strategy("NORTH_SOUTH_PORT_PREPROCESSOR"),
    ),
  )
  assert_true(
    polyline_edge_router_test_contains_factory(
      configuration.processors_before(p4_node_placement),
      polyline_edge_router_test_strategy("SELF_LOOP_PORT_RESTORER"),
    ),
  )
  assert_true(
    polyline_edge_router_test_contains_factory(
      configuration.processors_before(p4_node_placement),
      polyline_edge_router_test_strategy("SELF_LOOP_ROUTER"),
    ),
  )
  assert_true(
    polyline_edge_router_test_contains_factory(
      configuration.processors_before(p4_node_placement),
      polyline_edge_router_test_strategy("LABEL_DUMMY_SWITCHER"),
    ),
  )
  assert_true(
    polyline_edge_router_test_contains_factory(
      configuration.processors_before(p4_node_placement),
      polyline_edge_router_test_strategy("LABEL_SIDE_SELECTOR"),
    ),
  )
  assert_true(
    polyline_edge_router_test_contains_factory(
      configuration.processors_before(p4_node_placement),
      polyline_edge_router_test_strategy("END_LABEL_PREPROCESSOR"),
    ),
  )
  assert_true(
    polyline_edge_router_test_contains_factory(
      configuration.processors_after(p5_edge_routing),
      polyline_edge_router_test_strategy("NORTH_SOUTH_PORT_POSTPROCESSOR"),
    ),
  )
  assert_true(
    polyline_edge_router_test_contains_factory(
      configuration.processors_after(p5_edge_routing),
      polyline_edge_router_test_strategy("SELF_LOOP_POSTPROCESSOR"),
    ),
  )
  assert_true(
    polyline_edge_router_test_contains_factory(
      configuration.processors_after(p5_edge_routing),
      polyline_edge_router_test_strategy("LABEL_DUMMY_REMOVER"),
    ),
  )
  assert_true(
    polyline_edge_router_test_contains_factory(
      configuration.processors_after(p5_edge_routing),
      polyline_edge_router_test_strategy("END_LABEL_POSTPROCESSOR"),
    ),
  )
}
