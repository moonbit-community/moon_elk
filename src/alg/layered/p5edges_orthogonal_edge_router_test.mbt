///|
fn orthogonal_edge_router_test_graph_property(name : String) -> GraphProperties {
  for property in graph_properties_values() {
    if graph_properties_to_string(property) == name {
      return property
    }
  }
  abort("unknown graph property")
}

///|
fn orthogonal_edge_router_test_strategy(
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
fn orthogonal_edge_router_test_port_side(name : String) -> @core.PortSide {
  for side in @core.port_side_values() {
    if @core.port_side_to_string(side) == name {
      return side
    }
  }
  abort("unknown port side")
}

///|
fn orthogonal_edge_router_test_contains_factory(
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
fn orthogonal_edge_router_test_build_two_layer_graph() -> (
  LGraph,
  LNode,
  LNode,
  LEdge,
) {
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
  left_port.set_side(orthogonal_edge_router_test_port_side("EAST"))
  left_port.set_node(Some(left_node))

  let right_port = new_l_port()
  right_port.set_side(orthogonal_edge_router_test_port_side("WEST"))
  right_port.set_node(Some(right_node))

  let edge = new_l_edge()
  edge.set_source(Some(left_port))
  edge.set_target(Some(right_port))

  (graph, left_node, right_node, edge)
}

///|
test "orthogonal edge router layout phase starts monitor with expected task" {
  let phase = new_orthogonal_edge_router_layout_phase()
  assert_true(phase.is_layout_phase())

  let monitor = new_elk_progress_monitor()
  phase.process(new_l_graph(), Some(monitor))
  inspect(monitor.get_task_name(), content="Orthogonal edge routing")
}

///|
test "orthogonal edge router process sets width to zero for empty layered graph" {
  let phase = new_orthogonal_edge_router_layout_phase()
  let graph = new_l_graph()
  graph.set_size_xy(123.0, graph.get_size().y)

  phase.process(graph, None)
  assert_eq(graph.get_size().x, 0.0)
}

///|
test "orthogonal edge router process routes two-layer graph and inserts bend points" {
  let phase = new_orthogonal_edge_router_layout_phase()
  let (graph, left_node, right_node, edge) = orthogonal_edge_router_test_build_two_layer_graph()

  phase.process(graph, None)

  assert_eq(left_node.get_position().x, 0.0)
  assert_eq(right_node.get_position().x, 50.0)
  assert_eq(graph.get_size().x, 90.0)

  let bends = edge.get_bend_points()
  assert_eq(bends.size(), 2)
  assert_eq(bends.get(0).x, 40.0)
  assert_eq(bends.get(0).y, 0.0)
  assert_eq(bends.get(1).x, 40.0)
  assert_eq(bends.get(1).y, 50.0)
}

///|
test "orthogonal edge router configuration baseline has no optional dependencies" {
  let phase = new_orthogonal_edge_router_layout_phase()
  let graph = new_l_graph()
  let configuration = match phase.get_layout_processor_configuration(graph) {
    Some(value) => value
    None => abort("orthogonal edge router configuration must exist")
  }
  let phases = layered_phase_constants()

  assert_eq(configuration.processors_before(phases[2]).length(), 0)
  assert_eq(configuration.processors_before(phases[3]).length(), 0)
  assert_eq(configuration.processors_after(phases[4]).length(), 0)
}

///|
test "orthogonal edge router configuration adds optional processors by graph properties" {
  let phase = new_orthogonal_edge_router_layout_phase()
  let graph = new_l_graph()
  graph.set_property_graph_properties_array(
    internal_properties_graph_properties,
    [
      orthogonal_edge_router_test_graph_property("HYPEREDGES"),
      orthogonal_edge_router_test_graph_property("NON_FREE_PORTS"),
      orthogonal_edge_router_test_graph_property("NORTH_SOUTH_PORTS"),
      orthogonal_edge_router_test_graph_property("EXTERNAL_PORTS"),
      orthogonal_edge_router_test_graph_property("SELF_LOOPS"),
      orthogonal_edge_router_test_graph_property("HYPERNODES"),
      orthogonal_edge_router_test_graph_property("CENTER_LABELS"),
      orthogonal_edge_router_test_graph_property("END_LABELS"),
    ],
  )

  let configuration = match phase.get_layout_processor_configuration(graph) {
    Some(value) => value
    None => abort("orthogonal edge router configuration must exist")
  }
  let phases = layered_phase_constants()
  let p1_cycle_breaking = phases[0]
  let p2_layering = phases[1]
  let p3_node_ordering = phases[2]
  let p4_node_placement = phases[3]
  let p5_edge_routing = phases[4]

  assert_true(
    orthogonal_edge_router_test_contains_factory(
      configuration.processors_before(p1_cycle_breaking),
      orthogonal_edge_router_test_strategy("SELF_LOOP_PREPROCESSOR"),
    ),
  )
  assert_true(
    orthogonal_edge_router_test_contains_factory(
      configuration.processors_before(p2_layering),
      orthogonal_edge_router_test_strategy("LABEL_DUMMY_INSERTER"),
    ),
  )
  assert_true(
    orthogonal_edge_router_test_contains_factory(
      configuration.processors_before(p3_node_ordering),
      orthogonal_edge_router_test_strategy("INVERTED_PORT_PROCESSOR"),
    ),
  )
  assert_true(
    orthogonal_edge_router_test_contains_factory(
      configuration.processors_before(p3_node_ordering),
      orthogonal_edge_router_test_strategy(
        "HIERARCHICAL_PORT_CONSTRAINT_PROCESSOR",
      ),
    ),
  )
  assert_true(
    orthogonal_edge_router_test_contains_factory(
      configuration.processors_before(p3_node_ordering),
      orthogonal_edge_router_test_strategy("NORTH_SOUTH_PORT_PREPROCESSOR"),
    ),
  )
  assert_true(
    orthogonal_edge_router_test_contains_factory(
      configuration.processors_before(p4_node_placement),
      orthogonal_edge_router_test_strategy("HYPEREDGE_DUMMY_MERGER"),
    ),
  )
  assert_true(
    orthogonal_edge_router_test_contains_factory(
      configuration.processors_before(p4_node_placement),
      orthogonal_edge_router_test_strategy(
        "HIERARCHICAL_PORT_DUMMY_SIZE_PROCESSOR",
      ),
    ),
  )
  assert_true(
    orthogonal_edge_router_test_contains_factory(
      configuration.processors_before(p4_node_placement),
      orthogonal_edge_router_test_strategy("SELF_LOOP_PORT_RESTORER"),
    ),
  )
  assert_true(
    orthogonal_edge_router_test_contains_factory(
      configuration.processors_before(p4_node_placement),
      orthogonal_edge_router_test_strategy("SELF_LOOP_ROUTER"),
    ),
  )
  assert_true(
    orthogonal_edge_router_test_contains_factory(
      configuration.processors_before(p4_node_placement),
      orthogonal_edge_router_test_strategy("LABEL_DUMMY_SWITCHER"),
    ),
  )
  assert_true(
    orthogonal_edge_router_test_contains_factory(
      configuration.processors_before(p4_node_placement),
      orthogonal_edge_router_test_strategy("LABEL_SIDE_SELECTOR"),
    ),
  )
  assert_true(
    orthogonal_edge_router_test_contains_factory(
      configuration.processors_before(p4_node_placement),
      orthogonal_edge_router_test_strategy("END_LABEL_PREPROCESSOR"),
    ),
  )
  assert_true(
    orthogonal_edge_router_test_contains_factory(
      configuration.processors_after(p5_edge_routing),
      orthogonal_edge_router_test_strategy("NORTH_SOUTH_PORT_POSTPROCESSOR"),
    ),
  )
  assert_true(
    orthogonal_edge_router_test_contains_factory(
      configuration.processors_after(p5_edge_routing),
      orthogonal_edge_router_test_strategy(
        "HIERARCHICAL_PORT_ORTHOGONAL_EDGE_ROUTER",
      ),
    ),
  )
  assert_true(
    orthogonal_edge_router_test_contains_factory(
      configuration.processors_after(p5_edge_routing),
      orthogonal_edge_router_test_strategy("SELF_LOOP_POSTPROCESSOR"),
    ),
  )
  assert_true(
    orthogonal_edge_router_test_contains_factory(
      configuration.processors_after(p5_edge_routing),
      orthogonal_edge_router_test_strategy("HYPERNODE_PROCESSOR"),
    ),
  )
  assert_true(
    orthogonal_edge_router_test_contains_factory(
      configuration.processors_after(p5_edge_routing),
      orthogonal_edge_router_test_strategy("LABEL_DUMMY_REMOVER"),
    ),
  )
  assert_true(
    orthogonal_edge_router_test_contains_factory(
      configuration.processors_after(p5_edge_routing),
      orthogonal_edge_router_test_strategy("END_LABEL_POSTPROCESSOR"),
    ),
  )
}
