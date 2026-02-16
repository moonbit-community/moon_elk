///|
fn basic_cycle_breaker_side_equals(left : PortSide, right : PortSide) -> Bool {
  port_side_to_string(left) == port_side_to_string(right)
}

///|
fn basic_cycle_breaker_west() -> PortSide {
  port_side_values()[4]
}

///|
fn basic_cycle_breaker_east() -> PortSide {
  port_side_values()[2]
}

///|
fn basic_cycle_breaker_add_layerless_node(graph : LGraph) -> LNode {
  let node = new_l_node(graph=Some(graph))
  graph.get_layerless_nodes().push(node)
  let input = new_l_port()
  input.set_side(basic_cycle_breaker_west())
  input.set_node(Some(node))
  node.add_port(input)
  let output = new_l_port()
  output.set_side(basic_cycle_breaker_east())
  output.set_node(Some(node))
  node.add_port(output)
  node
}

///|
fn basic_cycle_breaker_input_port(node : LNode) -> LPort {
  for port in node.get_ports() {
    if basic_cycle_breaker_side_equals(
        port.get_side(),
        basic_cycle_breaker_west(),
      ) {
      return port
    }
  }
  abort("input port missing")
}

///|
fn basic_cycle_breaker_output_port(node : LNode) -> LPort {
  for port in node.get_ports() {
    if basic_cycle_breaker_side_equals(
        port.get_side(),
        basic_cycle_breaker_east(),
      ) {
      return port
    }
  }
  abort("output port missing")
}

///|
fn basic_cycle_breaker_connect(source : LNode, target : LNode) -> LEdge {
  let edge = new_l_edge()
  edge.set_source(Some(basic_cycle_breaker_output_port(source)))
  edge.set_target(Some(basic_cycle_breaker_input_port(target)))
  edge
}

///|
fn basic_cycle_breaker_target_node(edge : LEdge) -> LNode? {
  match edge.get_target() {
    Some(port) =>
      match port.get_node() {
        Some(node) => Some(node)
        None => None
      }
    None => None
  }
}

///|
fn basic_cycle_breaker_node_equals(left : LNode, right : LNode) -> Bool {
  left.get_handle() == right.get_handle()
}

///|
fn basic_cycle_breaker_find_edge(source : LNode, target : LNode) -> LEdge? {
  for edge in source.get_outgoing_edges() {
    match basic_cycle_breaker_target_node(edge) {
      Some(node) =>
        if basic_cycle_breaker_node_equals(node, target) {
          return Some(edge)
        }
      None => ()
    }
  }
  None
}

///|
fn basic_cycle_breaker_state_of(states : Map[Int, Int], node : LNode) -> Int {
  match states.get(node.get_handle()) {
    Some(value) => value
    None => 0
  }
}

///|
fn basic_cycle_breaker_dfs_cycle(node : LNode, states : Map[Int, Int]) -> Bool {
  let state = basic_cycle_breaker_state_of(states, node)
  if state == 1 {
    return true
  }
  if state == 2 {
    return false
  }

  states[node.get_handle()] = 1
  for edge in node.get_outgoing_edges() {
    match basic_cycle_breaker_target_node(edge) {
      Some(target) =>
        if basic_cycle_breaker_dfs_cycle(target, states) {
          return true
        }
      None => ()
    }
  }
  states[node.get_handle()] = 2
  false
}

///|
fn basic_cycle_breaker_has_cycle(graph : LGraph) -> Bool {
  let states = {}
  for node in graph.get_layerless_nodes() {
    if basic_cycle_breaker_state_of(states, node) == 0 &&
      basic_cycle_breaker_dfs_cycle(node, states) {
      return true
    }
  }
  false
}

///|
fn basic_cycle_breaker_factory_ids(
  factories : Array[ILayoutProcessorFactory[LayeredPhases, LGraph]],
) -> Array[Int] {
  let ids = []
  for factory in factories {
    ids.push(factory.factory_id())
  }
  ids
}

///|
test "DepthFirstCycleBreaker removes directed 3-cycle" {
  let graph = new_l_graph()
  let n1 = basic_cycle_breaker_add_layerless_node(graph)
  let n2 = basic_cycle_breaker_add_layerless_node(graph)
  let n3 = basic_cycle_breaker_add_layerless_node(graph)
  ignore(basic_cycle_breaker_connect(n1, n2))
  ignore(basic_cycle_breaker_connect(n2, n3))
  ignore(basic_cycle_breaker_connect(n3, n1))

  assert_eq(basic_cycle_breaker_has_cycle(graph), true)

  let phase = new_depth_first_cycle_breaker_layout_phase()
  phase.process(graph, None)

  assert_eq(basic_cycle_breaker_has_cycle(graph), false)
  assert_eq(graph.get_property_bool(internal_properties_cyclic), true)
}

///|
test "DepthFirstCycleBreaker adds reversed-edge-restorer slot after P5" {
  let graph = new_l_graph()
  let phase = new_depth_first_cycle_breaker_layout_phase()
  let configuration = match phase.get_layout_processor_configuration(graph) {
    Some(value) => value
    None => abort("depth-first configuration must exist")
  }
  let phase_constants = layered_phase_constants()
  let p5_edge_routing = phase_constants[4]
  assert_eq(
    basic_cycle_breaker_factory_ids(
      configuration.processors_after(p5_edge_routing),
    ),
    [23054],
  )
}

///|
test "InteractiveCycleBreaker reverses right-to-left edge by node x position" {
  let graph = new_l_graph()
  let left = basic_cycle_breaker_add_layerless_node(graph)
  let right = basic_cycle_breaker_add_layerless_node(graph)
  ignore(left.get_position().set_xy(0.0, left.get_position().y))
  ignore(right.get_position().set_xy(100.0, right.get_position().y))
  ignore(basic_cycle_breaker_connect(right, left))

  assert_eq(
    match basic_cycle_breaker_find_edge(right, left) {
      Some(_) => true
      None => false
    },
    true,
  )

  let phase = new_interactive_cycle_breaker_layout_phase()
  phase.process(graph, None)

  assert_eq(
    match basic_cycle_breaker_find_edge(right, left) {
      Some(_) => true
      None => false
    },
    false,
  )
  let reversed_edge = match basic_cycle_breaker_find_edge(left, right) {
    Some(value) => value
    None => abort("edge should be reversed")
  }
  assert_eq(reversed_edge.get_property_bool(internal_properties_reversed), true)
  assert_eq(graph.get_property_bool(internal_properties_cyclic), true)
}

///|
test "InteractiveCycleBreaker fallback DFS removes cycle when x is tied" {
  let graph = new_l_graph()
  let n1 = basic_cycle_breaker_add_layerless_node(graph)
  let n2 = basic_cycle_breaker_add_layerless_node(graph)
  let n3 = basic_cycle_breaker_add_layerless_node(graph)
  ignore(n1.get_position().set_xy(0.0, n1.get_position().y))
  ignore(n2.get_position().set_xy(0.0, n2.get_position().y))
  ignore(n3.get_position().set_xy(0.0, n3.get_position().y))
  ignore(basic_cycle_breaker_connect(n1, n2))
  ignore(basic_cycle_breaker_connect(n2, n3))
  ignore(basic_cycle_breaker_connect(n3, n1))

  assert_eq(basic_cycle_breaker_has_cycle(graph), true)

  let phase = new_interactive_cycle_breaker_layout_phase()
  phase.process(graph, None)

  assert_eq(basic_cycle_breaker_has_cycle(graph), false)
  assert_eq(graph.get_property_bool(internal_properties_cyclic), true)
}

///|
test "InteractiveCycleBreaker config adds pre-P1 and post-P5 processors" {
  let graph = new_l_graph()
  let phase = new_interactive_cycle_breaker_layout_phase()
  let configuration = match phase.get_layout_processor_configuration(graph) {
    Some(value) => value
    None => abort("interactive configuration must exist")
  }
  let phase_constants = layered_phase_constants()
  let p1_cycle_breaking = phase_constants[0]
  let p5_edge_routing = phase_constants[4]
  assert_eq(
    basic_cycle_breaker_factory_ids(
      configuration.processors_before(p1_cycle_breaking),
    ),
    [23003],
  )
  assert_eq(
    basic_cycle_breaker_factory_ids(
      configuration.processors_after(p5_edge_routing),
    ),
    [23054],
  )
}

///|
test "BFSNodeOrderCycleBreaker removes directed 3-cycle" {
  let graph = new_l_graph()
  let n1 = basic_cycle_breaker_add_layerless_node(graph)
  let n2 = basic_cycle_breaker_add_layerless_node(graph)
  let n3 = basic_cycle_breaker_add_layerless_node(graph)
  n1.set_property_int(internal_properties_model_order, 0)
  n2.set_property_int(internal_properties_model_order, 1)
  n3.set_property_int(internal_properties_model_order, 2)
  ignore(basic_cycle_breaker_connect(n1, n2))
  ignore(basic_cycle_breaker_connect(n2, n3))
  ignore(basic_cycle_breaker_connect(n3, n1))

  assert_eq(basic_cycle_breaker_has_cycle(graph), true)

  let phase = new_bfs_node_order_cycle_breaker_layout_phase()
  phase.process(graph, None)

  assert_eq(basic_cycle_breaker_has_cycle(graph), false)
  assert_eq(graph.get_property_bool(internal_properties_cyclic), true)
}

///|
test "BFSNodeOrderCycleBreaker adds reversed-edge-restorer slot after P5" {
  let graph = new_l_graph()
  let phase = new_bfs_node_order_cycle_breaker_layout_phase()
  let configuration = match phase.get_layout_processor_configuration(graph) {
    Some(value) => value
    None => abort("bfs configuration must exist")
  }
  let phase_constants = layered_phase_constants()
  let p5_edge_routing = phase_constants[4]
  assert_eq(
    basic_cycle_breaker_factory_ids(
      configuration.processors_after(p5_edge_routing),
    ),
    [23054],
  )
}

///|
test "DFSNodeOrderCycleBreaker removes directed 3-cycle" {
  let graph = new_l_graph()
  let n1 = basic_cycle_breaker_add_layerless_node(graph)
  let n2 = basic_cycle_breaker_add_layerless_node(graph)
  let n3 = basic_cycle_breaker_add_layerless_node(graph)
  n1.set_property_int(internal_properties_model_order, 0)
  n2.set_property_int(internal_properties_model_order, 1)
  n3.set_property_int(internal_properties_model_order, 2)
  ignore(basic_cycle_breaker_connect(n1, n2))
  ignore(basic_cycle_breaker_connect(n2, n3))
  ignore(basic_cycle_breaker_connect(n3, n1))

  assert_eq(basic_cycle_breaker_has_cycle(graph), true)

  let phase = new_dfs_node_order_cycle_breaker_layout_phase()
  phase.process(graph, None)

  assert_eq(basic_cycle_breaker_has_cycle(graph), false)
  assert_eq(graph.get_property_bool(internal_properties_cyclic), true)
}

///|
test "DFSNodeOrderCycleBreaker adds reversed-edge-restorer slot after P5" {
  let graph = new_l_graph()
  let phase = new_dfs_node_order_cycle_breaker_layout_phase()
  let configuration = match phase.get_layout_processor_configuration(graph) {
    Some(value) => value
    None => abort("dfs node-order configuration must exist")
  }
  let phase_constants = layered_phase_constants()
  let p5_edge_routing = phase_constants[4]
  assert_eq(
    basic_cycle_breaker_factory_ids(
      configuration.processors_after(p5_edge_routing),
    ),
    [23054],
  )
}

///|
test "ModelOrderCycleBreaker removes backward edge by model order" {
  let graph = new_l_graph()
  let n1 = basic_cycle_breaker_add_layerless_node(graph)
  let n2 = basic_cycle_breaker_add_layerless_node(graph)
  let n3 = basic_cycle_breaker_add_layerless_node(graph)
  n1.set_property_int(internal_properties_model_order, 0)
  n2.set_property_int(internal_properties_model_order, 1)
  n3.set_property_int(internal_properties_model_order, 2)
  ignore(basic_cycle_breaker_connect(n1, n2))
  ignore(basic_cycle_breaker_connect(n2, n3))
  ignore(basic_cycle_breaker_connect(n3, n1))

  assert_eq(basic_cycle_breaker_has_cycle(graph), true)

  let phase = new_model_order_cycle_breaker_layout_phase()
  phase.process(graph, None)

  assert_eq(basic_cycle_breaker_has_cycle(graph), false)
  assert_eq(graph.get_property_bool(internal_properties_cyclic), true)
}

///|
test "ModelOrderCycleBreaker adds reversed-edge-restorer slot after P5" {
  let graph = new_l_graph()
  let phase = new_model_order_cycle_breaker_layout_phase()
  let configuration = match phase.get_layout_processor_configuration(graph) {
    Some(value) => value
    None => abort("model-order configuration must exist")
  }
  let phase_constants = layered_phase_constants()
  let p5_edge_routing = phase_constants[4]
  assert_eq(
    basic_cycle_breaker_factory_ids(
      configuration.processors_after(p5_edge_routing),
    ),
    [23054],
  )
}

///|
test "GreedyCycleBreaker removes directed 3-cycle" {
  let graph = new_l_graph()
  let n1 = basic_cycle_breaker_add_layerless_node(graph)
  let n2 = basic_cycle_breaker_add_layerless_node(graph)
  let n3 = basic_cycle_breaker_add_layerless_node(graph)
  ignore(basic_cycle_breaker_connect(n1, n2))
  ignore(basic_cycle_breaker_connect(n2, n3))
  ignore(basic_cycle_breaker_connect(n3, n1))

  assert_eq(basic_cycle_breaker_has_cycle(graph), true)

  let phase = new_greedy_cycle_breaker_layout_phase()
  phase.process(graph, None)

  assert_eq(basic_cycle_breaker_has_cycle(graph), false)
  assert_eq(graph.get_property_bool(internal_properties_cyclic), true)
}

///|
test "GreedyCycleBreaker adds reversed-edge-restorer slot after P5" {
  let graph = new_l_graph()
  let phase = new_greedy_cycle_breaker_layout_phase()
  let configuration = match phase.get_layout_processor_configuration(graph) {
    Some(value) => value
    None => abort("greedy configuration must exist")
  }
  let phase_constants = layered_phase_constants()
  let p5_edge_routing = phase_constants[4]
  assert_eq(
    basic_cycle_breaker_factory_ids(
      configuration.processors_after(p5_edge_routing),
    ),
    [23054],
  )
}

///|
test "GreedyModelOrderCycleBreaker removes directed 3-cycle" {
  let graph = new_l_graph()
  let n1 = basic_cycle_breaker_add_layerless_node(graph)
  let n2 = basic_cycle_breaker_add_layerless_node(graph)
  let n3 = basic_cycle_breaker_add_layerless_node(graph)
  n1.set_property_int(internal_properties_model_order, 0)
  n2.set_property_int(internal_properties_model_order, 1)
  n3.set_property_int(internal_properties_model_order, 2)
  ignore(basic_cycle_breaker_connect(n1, n2))
  ignore(basic_cycle_breaker_connect(n2, n3))
  ignore(basic_cycle_breaker_connect(n3, n1))

  assert_eq(basic_cycle_breaker_has_cycle(graph), true)

  let phase = new_greedy_model_order_cycle_breaker_layout_phase()
  phase.process(graph, None)

  assert_eq(basic_cycle_breaker_has_cycle(graph), false)
  assert_eq(graph.get_property_bool(internal_properties_cyclic), true)
}

///|
test "GreedyModelOrderCycleBreaker adds reversed-edge-restorer slot after P5" {
  let graph = new_l_graph()
  let phase = new_greedy_model_order_cycle_breaker_layout_phase()
  let configuration = match phase.get_layout_processor_configuration(graph) {
    Some(value) => value
    None => abort("greedy model-order configuration must exist")
  }
  let phase_constants = layered_phase_constants()
  let p5_edge_routing = phase_constants[4]
  assert_eq(
    basic_cycle_breaker_factory_ids(
      configuration.processors_after(p5_edge_routing),
    ),
    [23054],
  )
}

///|
test "SCCModelOrderCycleBreaker removes directed 3-cycle" {
  let graph = new_l_graph()
  let n1 = basic_cycle_breaker_add_layerless_node(graph)
  let n2 = basic_cycle_breaker_add_layerless_node(graph)
  let n3 = basic_cycle_breaker_add_layerless_node(graph)
  n1.set_property_int(internal_properties_model_order, 0)
  n2.set_property_int(internal_properties_model_order, 1)
  n3.set_property_int(internal_properties_model_order, 2)
  ignore(basic_cycle_breaker_connect(n1, n2))
  ignore(basic_cycle_breaker_connect(n2, n3))
  ignore(basic_cycle_breaker_connect(n3, n1))

  assert_eq(basic_cycle_breaker_has_cycle(graph), true)

  let phase = new_scc_model_order_cycle_breaker_layout_phase()
  phase.process(graph, None)

  assert_eq(basic_cycle_breaker_has_cycle(graph), false)
  assert_eq(graph.get_property_bool(internal_properties_cyclic), true)
}

///|
test "SCCModelOrderCycleBreaker adds reversed-edge-restorer slot after P5" {
  let graph = new_l_graph()
  let phase = new_scc_model_order_cycle_breaker_layout_phase()
  let configuration = match phase.get_layout_processor_configuration(graph) {
    Some(value) => value
    None => abort("scc model-order configuration must exist")
  }
  let phase_constants = layered_phase_constants()
  let p5_edge_routing = phase_constants[4]
  assert_eq(
    basic_cycle_breaker_factory_ids(
      configuration.processors_after(p5_edge_routing),
    ),
    [23054],
  )
}

///|
test "SCConnectivityCycleBreaker removes directed 3-cycle" {
  let graph = new_l_graph()
  let n1 = basic_cycle_breaker_add_layerless_node(graph)
  let n2 = basic_cycle_breaker_add_layerless_node(graph)
  let n3 = basic_cycle_breaker_add_layerless_node(graph)
  n1.set_property_int(internal_properties_model_order, 0)
  n2.set_property_int(internal_properties_model_order, 1)
  n3.set_property_int(internal_properties_model_order, 2)
  ignore(basic_cycle_breaker_connect(n1, n2))
  ignore(basic_cycle_breaker_connect(n2, n3))
  ignore(basic_cycle_breaker_connect(n3, n1))

  assert_eq(basic_cycle_breaker_has_cycle(graph), true)

  let phase = new_sc_connectivity_cycle_breaker_layout_phase()
  phase.process(graph, None)

  assert_eq(basic_cycle_breaker_has_cycle(graph), false)
  assert_eq(graph.get_property_bool(internal_properties_cyclic), true)
}

///|
test "SCConnectivityCycleBreaker adds reversed-edge-restorer slot after P5" {
  let graph = new_l_graph()
  let phase = new_sc_connectivity_cycle_breaker_layout_phase()
  let configuration = match phase.get_layout_processor_configuration(graph) {
    Some(value) => value
    None => abort("sc-connectivity configuration must exist")
  }
  let phase_constants = layered_phase_constants()
  let p5_edge_routing = phase_constants[4]
  assert_eq(
    basic_cycle_breaker_factory_ids(
      configuration.processors_after(p5_edge_routing),
    ),
    [23054],
  )
}

///|
test "SCCNodeTypeCycleBreaker honors preferred source node id" {
  let graph = new_l_graph()
  let n1 = basic_cycle_breaker_add_layerless_node(graph)
  let n2 = basic_cycle_breaker_add_layerless_node(graph)
  let n3 = basic_cycle_breaker_add_layerless_node(graph)
  n1.set_property_int(internal_properties_model_order, 0)
  n2.set_property_int(internal_properties_model_order, 1)
  n3.set_property_int(internal_properties_model_order, 2)
  n1.set_property_int(
    layered_options_consider_model_order_group_model_order_cycle_breaking_id, 42,
  )
  n2.set_property_int(
    layered_options_consider_model_order_group_model_order_cycle_breaking_id, 7,
  )
  n3.set_property_int(
    layered_options_consider_model_order_group_model_order_cycle_breaking_id, 9,
  )
  graph.set_property_int(
    layered_options_consider_model_order_group_model_order_cb_preferred_source_id,
    42,
  )
  graph.set_property_int(
    layered_options_consider_model_order_group_model_order_cb_preferred_target_id,
    -1,
  )
  ignore(basic_cycle_breaker_connect(n1, n2))
  ignore(basic_cycle_breaker_connect(n2, n3))
  ignore(basic_cycle_breaker_connect(n3, n1))

  assert_eq(
    match basic_cycle_breaker_find_edge(n3, n1) {
      Some(_) => true
      None => false
    },
    true,
  )

  let phase = new_scc_node_type_cycle_breaker_layout_phase()
  phase.process(graph, None)

  assert_eq(basic_cycle_breaker_has_cycle(graph), false)
  assert_eq(
    match basic_cycle_breaker_find_edge(n3, n1) {
      Some(_) => true
      None => false
    },
    false,
  )
  let reversed_edge = match basic_cycle_breaker_find_edge(n1, n3) {
    Some(value) => value
    None => abort("preferred-source incoming edge should be reversed")
  }
  assert_eq(reversed_edge.get_property_bool(internal_properties_reversed), true)
  assert_eq(graph.get_property_bool(internal_properties_cyclic), true)
}

///|
test "SCCNodeTypeCycleBreaker adds reversed-edge-restorer slot after P5" {
  let graph = new_l_graph()
  let phase = new_scc_node_type_cycle_breaker_layout_phase()
  let configuration = match phase.get_layout_processor_configuration(graph) {
    Some(value) => value
    None => abort("scc node-type configuration must exist")
  }
  let phase_constants = layered_phase_constants()
  let p5_edge_routing = phase_constants[4]
  assert_eq(
    basic_cycle_breaker_factory_ids(
      configuration.processors_after(p5_edge_routing),
    ),
    [23054],
  )
}
