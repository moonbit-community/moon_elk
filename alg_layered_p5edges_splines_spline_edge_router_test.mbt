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
  graph.set_property_graph_properties_array(internal_properties_graph_properties, [
    spline_edge_router_test_graph_property("SELF_LOOPS"),
    spline_edge_router_test_graph_property("CENTER_LABELS"),
    spline_edge_router_test_graph_property("NORTH_SOUTH_PORTS"),
    spline_edge_router_test_graph_property("END_LABELS"),
  ])

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
