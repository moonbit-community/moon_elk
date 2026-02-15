///|
fn interactive_node_placer_test_add_layer(graph : LGraph) -> Layer {
  let layer = new_layer(graph)
  graph.get_layers().push(layer)
  layer
}

///|
fn interactive_node_placer_test_node_type(name : String) -> NodeType {
  let values = node_type_values()
  if name == "NORMAL" {
    return values[0]
  }
  if name == "LONG_EDGE" {
    return values[1]
  }
  if name == "EXTERNAL_PORT" {
    return values[2]
  }
  if name == "NORTH_SOUTH_PORT" {
    return values[3]
  }
  if name == "LABEL_NODE" {
    return values[4]
  }
  if name == "BREAKING_POINT" {
    return values[5]
  }
  if name == "PLACEHOLDER" {
    return values[6]
  }
  if name == "NONSHIFTING_PLACEHOLDER" {
    return values[7]
  }
  abort("unknown node type")
}

///|
fn interactive_node_placer_test_graph_property(
  name : String,
) -> GraphProperties {
  for property in graph_properties_values() {
    if graph_properties_to_string(property) == name {
      return property
    }
  }
  abort("unknown graph property")
}

///|
fn interactive_node_placer_test_strategy(
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
fn interactive_node_placer_test_add_node(
  layer : Layer,
  node_type : NodeType,
  y : Double,
  height : Double,
) -> LNode {
  let node = new_l_node()
  node.set_type(node_type)
  node.set_layer(Some(layer))
  ignore(node.get_position().set_xy(node.get_position().x, y))
  ignore(node.get_size().set_xy(10.0, height))
  node.get_margin().set_top(0.0)
  node.get_margin().set_bottom(0.0)
  node
}

///|
fn interactive_node_placer_test_contains_factory(
  factories : Array[ILayoutProcessorFactory[LayeredPhases, LGraph]],
  expected_factory_id : Int,
) -> Bool {
  for factory in factories {
    if factory.factory_id() == expected_factory_id {
      return true
    }
  }
  false
}

///|
test "interactive node placer layout phase starts monitor with expected task" {
  let phase = new_interactive_node_placer_layout_phase()
  assert_true(phase.is_layout_phase())

  let monitor = new_elk_progress_monitor()
  phase.process(new_l_graph(), Some(monitor))
  inspect(monitor.get_task_name(), content="Interactive node placement")
}

///|
test "interactive node placer restores ORIGINAL_DUMMY_NODE_POSITION for dummy nodes" {
  let graph = new_l_graph()
  graph.set_property_double(spacing_edge_node, 0.0)
  let layer = interactive_node_placer_test_add_layer(graph)
  let dummy = interactive_node_placer_test_add_node(
    layer,
    interactive_node_placer_test_node_type("LONG_EDGE"),
    0.0,
    5.0,
  )
  dummy.set_property_double(
    internal_properties_original_dummy_node_position, 42.0,
  )

  let phase = new_interactive_node_placer_layout_phase()
  phase.process(graph, None)

  assert_eq(dummy.get_position().y, 42.0)
}

///|
test "interactive node placer computes dummy y from min valid y when original is missing" {
  let graph = new_l_graph()
  graph.set_property_double(spacing_node_node, 0.0)
  graph.set_property_double(spacing_edge_node, 0.0)
  let layer = interactive_node_placer_test_add_layer(graph)
  let normal = interactive_node_placer_test_add_node(
    layer,
    interactive_node_placer_test_node_type("NORMAL"),
    5.0,
    10.0,
  )
  let dummy = interactive_node_placer_test_add_node(
    layer,
    interactive_node_placer_test_node_type("LONG_EDGE"),
    -100.0,
    4.0,
  )

  let phase = new_interactive_node_placer_layout_phase()
  phase.process(graph, None)

  assert_eq(normal.get_position().y, 5.0)
  assert_eq(dummy.get_position().y, 15.0)
}

///|
test "interactive node placer shifts overlapping normal nodes downward" {
  let graph = new_l_graph()
  graph.set_property_double(spacing_node_node, 0.0)
  let layer = interactive_node_placer_test_add_layer(graph)
  ignore(
    interactive_node_placer_test_add_node(
      layer,
      interactive_node_placer_test_node_type("NORMAL"),
      20.0,
      10.0,
    ),
  )
  let second = interactive_node_placer_test_add_node(
    layer,
    interactive_node_placer_test_node_type("NORMAL"),
    25.0,
    10.0,
  )

  let phase = new_interactive_node_placer_layout_phase()
  phase.process(graph, None)

  assert_eq(second.get_position().y, 30.0)
}

///|
test "interactive node placer config adds hierarchical port position processor for external ports" {
  let phase = new_interactive_node_placer_layout_phase()
  let graph = new_l_graph()
  graph.set_property_graph_properties_array(
    internal_properties_graph_properties,
    [interactive_node_placer_test_graph_property("EXTERNAL_PORTS")],
  )

  let configuration = match phase.get_layout_processor_configuration(graph) {
    Some(value) => value
    None => abort("interactive node placer configuration must exist")
  }

  let p5 = layered_phase_constants()[4]
  let expected = layered_intermediate_processor_factory(
    interactive_node_placer_test_strategy(
      "HIERARCHICAL_PORT_POSITION_PROCESSOR",
    ),
  ).factory_id()
  assert_true(
    interactive_node_placer_test_contains_factory(
      configuration.processors_before(p5),
      expected,
    ),
  )
}

///|
test "interactive node placer config is none without external ports" {
  let phase = new_interactive_node_placer_layout_phase()
  let graph = new_l_graph()
  assert_eq(
    match phase.get_layout_processor_configuration(graph) {
      Some(_) => true
      None => false
    },
    false,
  )
}
