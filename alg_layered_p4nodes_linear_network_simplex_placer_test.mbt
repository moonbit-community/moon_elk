///|
fn p4nodes_test_graph_property(name : String) -> GraphProperties {
  for property in graph_properties_values() {
    if graph_properties_to_string(property) == name {
      return property
    }
  }
  abort("unknown graph property")
}

///|
fn p4nodes_test_strategy(name : String) -> IntermediateProcessorStrategy {
  for strategy in intermediate_processor_strategy_values() {
    if intermediate_processor_strategy_to_string(strategy) == name {
      return strategy
    }
  }
  abort("unknown intermediate strategy")
}

///|
fn p4nodes_test_contains_factory(
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
fn p4nodes_test_expected_hierarchical_port_position_factory_id() -> Int {
  layered_intermediate_processor_factory(
    p4nodes_test_strategy("HIERARCHICAL_PORT_POSITION_PROCESSOR"),
  ).factory_id()
}

///|
fn p4nodes_test_external_ports_graph() -> LGraph {
  let graph = new_l_graph()
  graph.set_property_graph_properties_array(
    internal_properties_graph_properties,
    [p4nodes_test_graph_property("EXTERNAL_PORTS")],
  )
  graph
}

///|
fn p4nodes_test_add_layer(graph : LGraph) -> Layer {
  let layer = new_layer(graph)
  graph.get_layers().push(layer)
  layer
}

///|
fn p4nodes_test_add_basic_node(layer : Layer, height : Double) -> LNode {
  let node = new_l_node()
  node.set_layer(Some(layer))
  ignore(node.get_size().set_xy(10.0, height))
  node.get_margin().set_top(0.0)
  node.get_margin().set_bottom(0.0)
  node
}

///|
fn p4nodes_test_assert_integral(value : Double) -> Bool {
  value == value.round()
}

///|
fn p4nodes_test_port_side(name : String) -> PortSide {
  for side in port_side_values() {
    if port_side_to_string(side) == name {
      return side
    }
  }
  abort("unknown port side")
}

///|
let p4nodes_test_network_simplex_node_flexibility : IProperty[String] = new_property(
  "org.eclipse.elk.layered.nodePlacement.networkSimplex.nodeFlexibility", "NONE",
)

///|
let p4nodes_test_network_simplex_node_flexibility_default : IProperty[String] = new_property(
  "org.eclipse.elk.layered.nodePlacement.networkSimplex.nodeFlexibility.default",
  "NONE",
)

///|
fn p4nodes_test_add_port(
  node : LNode,
  side : PortSide,
  anchor_y : Double,
  position_y : Double,
) -> LPort {
  let port = new_l_port()
  port.set_node(Some(node))
  port.set_side(side)
  ignore(port.get_anchor().set_xy(port.get_anchor().x, anchor_y))
  ignore(port.get_position().set_xy(port.get_position().x, position_y))
  port
}

///|
fn p4nodes_test_connect_nodes(source : LNode, target : LNode) -> LEdge {
  let source_port = new_l_port()
  source_port.set_node(Some(source))
  source_port.set_side(p4nodes_test_port_side("EAST"))

  let target_port = new_l_port()
  target_port.set_node(Some(target))
  target_port.set_side(p4nodes_test_port_side("WEST"))

  let edge = new_l_edge()
  edge.set_source(Some(source_port))
  edge.set_target(Some(target_port))
  edge
}

///|
test "linear segments node placer layout phase starts monitor with expected task" {
  let phase = new_linear_segments_node_placer_layout_phase()
  assert_true(phase.is_layout_phase())

  let monitor = new_elk_progress_monitor()
  phase.process(new_l_graph(), Some(monitor))
  inspect(monitor.get_task_name(), content="Linear segments node placement")
}

///|
test "linear segments node placer config adds hierarchical port position processor for external ports" {
  let phase = new_linear_segments_node_placer_layout_phase()
  let graph = p4nodes_test_external_ports_graph()

  let configuration = match phase.get_layout_processor_configuration(graph) {
    Some(value) => value
    None => abort("linear segments node placer configuration must exist")
  }

  let p5 = layered_phase_constants()[4]
  assert_true(
    p4nodes_test_contains_factory(
      configuration.processors_before(p5),
      p4nodes_test_expected_hierarchical_port_position_factory_id(),
    ),
  )
}

///|
test "linear segments node placer uses spacing_edge_edge for first segment placement" {
  let phase = new_linear_segments_node_placer_layout_phase()
  let graph = new_l_graph()
  graph.set_property_double(spacing_edge_edge, 13.0)

  let layer = p4nodes_test_add_layer(graph)
  let node = p4nodes_test_add_basic_node(layer, 5.0)

  phase.process(graph, None)

  assert_eq(node.get_position().y, 13.0)
  assert_eq(layer.get_size().y, 18.0)
}

///|
test "linear segments node placer config is none without external ports" {
  let phase = new_linear_segments_node_placer_layout_phase()
  let graph = new_l_graph()
  assert_eq(
    match phase.get_layout_processor_configuration(graph) {
      Some(_) => true
      None => false
    },
    false,
  )
}

///|
test "network simplex node placer integerifies non-flexible port y positions during prepare" {
  let graph = new_l_graph()
  let layer = p4nodes_test_add_layer(graph)
  let node = p4nodes_test_add_basic_node(layer, 10.0)

  let port = p4nodes_test_add_port(
    node,
    p4nodes_test_port_side("EAST"),
    0.4,
    2.2,
  )

  let phase = new_network_simplex_placer_layout_phase()
  phase.process(graph, None)

  let y_sum = port.get_position().y + port.get_anchor().y
  assert_true(p4nodes_test_assert_integral(y_sum))
  assert_eq(port.get_anchor().y, 0.4)
}

///|
test "network simplex node placer integerifies flexible node anchor and absolute port y" {
  let graph = new_l_graph()
  let layer = p4nodes_test_add_layer(graph)
  let node = p4nodes_test_add_basic_node(layer, 100.0)
  node.set_property_string(port_constraints, "FIXED_ORDER")
  node.set_property_string(
    p4nodes_test_network_simplex_node_flexibility, "PORT_POSITION",
  )

  let east_port = p4nodes_test_add_port(
    node,
    p4nodes_test_port_side("EAST"),
    0.4,
    2.2,
  )
  ignore(p4nodes_test_add_port(node, p4nodes_test_port_side("WEST"), 0.0, 7.0))

  let phase = new_network_simplex_placer_layout_phase()
  phase.process(graph, None)

  assert_true(p4nodes_test_assert_integral(east_port.get_anchor().y))
  assert_true(
    p4nodes_test_assert_integral(
      east_port.get_position().y + east_port.get_anchor().y,
    ),
  )
}

///|
test "network simplex node placer does not integerify one-port PORT_POSITION anchor" {
  let graph = new_l_graph()
  let layer = p4nodes_test_add_layer(graph)
  let node = p4nodes_test_add_basic_node(layer, 100.0)
  node.set_property_string(port_constraints, "FIXED_ORDER")
  node.set_property_string(
    p4nodes_test_network_simplex_node_flexibility, "PORT_POSITION",
  )

  let port = p4nodes_test_add_port(
    node,
    p4nodes_test_port_side("EAST"),
    0.4,
    2.2,
  )

  let phase = new_network_simplex_placer_layout_phase()
  phase.process(graph, None)

  assert_eq(port.get_anchor().y, 0.4)
  assert_true(
    p4nodes_test_assert_integral(port.get_position().y + port.get_anchor().y),
  )
}

///|
test "network simplex node placer uses graph default flexibility during prepare" {
  let graph = new_l_graph()
  graph.set_property_string(
    p4nodes_test_network_simplex_node_flexibility_default, "PORT_POSITION",
  )
  let layer = p4nodes_test_add_layer(graph)
  let node = p4nodes_test_add_basic_node(layer, 100.0)
  node.set_property_string(port_constraints, "FIXED_ORDER")

  let east_port = p4nodes_test_add_port(
    node,
    p4nodes_test_port_side("EAST"),
    0.4,
    2.2,
  )
  ignore(p4nodes_test_add_port(node, p4nodes_test_port_side("WEST"), 0.0, 7.0))

  let phase = new_network_simplex_placer_layout_phase()
  phase.process(graph, None)

  assert_true(p4nodes_test_assert_integral(east_port.get_anchor().y))
}

///|
test "network simplex node placer prepare assigns sequential node and edge ids" {
  let graph = new_l_graph()
  let layer = p4nodes_test_add_layer(graph)
  let source = p4nodes_test_add_basic_node(layer, 10.0)
  let target = p4nodes_test_add_basic_node(layer, 10.0)
  let edge = p4nodes_test_connect_nodes(source, target)

  let phase = new_network_simplex_placer_layout_phase()
  phase.process(graph, None)

  assert_eq(source.get_id(), 0)
  assert_eq(target.get_id(), 1)
  assert_eq(edge.get_id(), 0)
}

///|
test "network simplex node placer layout phase starts monitor with expected task" {
  let phase = new_network_simplex_placer_layout_phase()
  assert_true(phase.is_layout_phase())

  let monitor = new_elk_progress_monitor()
  phase.process(new_l_graph(), Some(monitor))
  inspect(monitor.get_task_name(), content="Network simplex node placement")
}

///|
test "network simplex node placer config adds hierarchical port position processor for external ports" {
  let phase = new_network_simplex_placer_layout_phase()
  let graph = p4nodes_test_external_ports_graph()

  let configuration = match phase.get_layout_processor_configuration(graph) {
    Some(value) => value
    None => abort("network simplex node placer configuration must exist")
  }

  let p5 = layered_phase_constants()[4]
  assert_true(
    p4nodes_test_contains_factory(
      configuration.processors_before(p5),
      p4nodes_test_expected_hierarchical_port_position_factory_id(),
    ),
  )
}

///|
test "network simplex node placer config is none without external ports" {
  let phase = new_network_simplex_placer_layout_phase()
  let graph = new_l_graph()
  assert_eq(
    match phase.get_layout_processor_configuration(graph) {
      Some(_) => true
      None => false
    },
    false,
  )
}
