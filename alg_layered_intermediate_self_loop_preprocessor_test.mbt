///|
struct SelfLoopPreprocessorTestGraph {
  test_graph : LGraph
  self_loop_node : LNode
  regular_ports : Map[Int, Bool]
  only_self_loop_ports : Map[Int, Bool]
  unconnected_ports : Map[Int, Bool]
}

///|
fn self_loop_preprocessor_test_add_port(
  port_set : Map[Int, Bool],
  port : LPort,
) -> Unit {
  port_set[lport_internal_handle(port)] = true
}

///|
fn self_loop_preprocessor_test_contains_port(
  l_node : LNode,
  handle : Int,
) -> Bool {
  for l_port in l_node.get_ports() {
    if lport_internal_handle(l_port) == handle {
      return true
    }
  }
  false
}

///|
fn self_loop_preprocessor_test_assert_node_contains_ports(
  l_node : LNode,
  port_set : Map[Int, Bool],
) -> Unit {
  for entry in port_set.to_array() {
    let (handle, _) = entry
    if !self_loop_preprocessor_test_contains_port(l_node, handle) {
      abort("node does not contain expected port")
    }
  }
}

///|
fn self_loop_preprocessor_test_add_ports(test_graph : SelfLoopPreprocessorTestGraph) -> Unit {
  self_loop_test_graph_creator_ports(test_graph.self_loop_node, 2, 2, 2, 1)

  let mut north = 10.0
  let mut east = 10.0
  let mut south = 10.0
  let mut west = 10.0

  for l_port in test_graph.self_loop_node.get_ports() {
    let position = l_port.get_position()
    match l_port.get_side() {
      North => {
        ignore(position.set(new_kvector_xy(north, 0.0)))
        north += 30.0
      }
      East => {
        ignore(
          position.set(
            new_kvector_xy(test_graph.self_loop_node.get_size().x, east),
          ),
        )
        east += 30.0
      }
      South => {
        ignore(
          position.set(
            new_kvector_xy(south, test_graph.self_loop_node.get_size().y),
          ),
        )
        south += 30.0
      }
      West => {
        ignore(position.set(new_kvector_xy(0.0, west)))
        west += 30.0
      }
      _ => abort("unexpected port side")
    }
  }
}

///|
fn self_loop_preprocessor_test_add_edges(test_graph : SelfLoopPreprocessorTestGraph) -> Unit {
  let ports = test_graph.self_loop_node.get_ports()

  ignore(self_loop_test_graph_creator_edge(ports[0], ports[1]))
  ignore(self_loop_test_graph_creator_edge(ports[1], ports[2]))
  ignore(self_loop_test_graph_creator_edge(ports[3], ports[4]))
  ignore(self_loop_test_graph_creator_edge(ports[4], ports[5]))

  self_loop_preprocessor_test_add_port(test_graph.regular_ports, ports[0])

  self_loop_preprocessor_test_add_port(test_graph.only_self_loop_ports, ports[1])
  self_loop_preprocessor_test_add_port(test_graph.only_self_loop_ports, ports[2])
  self_loop_preprocessor_test_add_port(test_graph.only_self_loop_ports, ports[3])
  self_loop_preprocessor_test_add_port(test_graph.only_self_loop_ports, ports[4])
  self_loop_preprocessor_test_add_port(test_graph.only_self_loop_ports, ports[5])

  self_loop_preprocessor_test_add_port(test_graph.unconnected_ports, ports[6])
  self_loop_preprocessor_test_add_port(test_graph.unconnected_ports, ports[7])
}

///|
fn self_loop_preprocessor_test_new_graph(
  constraints : PortConstraints,
) -> SelfLoopPreprocessorTestGraph {
  let test_graph = self_loop_test_graph_creator_basic_graph_without_self_loops()
  let self_loop_node = test_graph.get_layerless_nodes()[1]
  self_loop_node.set_property_string(
    port_constraints,
    port_constraints_to_string(constraints),
  )
  ignore(self_loop_node.get_size().set(new_kvector_xy(50.0, 50.0)))

  let result : SelfLoopPreprocessorTestGraph = {
    test_graph,
    self_loop_node,
    regular_ports: {},
    only_self_loop_ports: {},
    unconnected_ports: {},
  }
  self_loop_preprocessor_test_add_ports(result)
  self_loop_preprocessor_test_add_edges(result)
  result
}

///|
fn self_loop_preprocessor_test_assert_hidden_edges(
  test_graph : SelfLoopPreprocessorTestGraph,
) -> Unit {
  for l_edge in test_graph.self_loop_node.get_connected_edges() {
    if l_edge.is_self_loop() {
      abort("self loop edge should have been hidden")
    }
  }
  if test_graph.self_loop_node.get_connected_edges().is_empty() {
    abort("regular edge should still be connected")
  }
}

///|
fn self_loop_preprocessor_test_ports_hidden(constraints : PortConstraints) -> Unit {
  let test_graph = self_loop_preprocessor_test_new_graph(constraints)
  let processor = new_self_loop_pre_processor_layout_processor()
  processor.process(test_graph.test_graph, Some(new_null_elk_progress_monitor()))

  if test_graph.self_loop_node.get_ports().length() !=
    test_graph.regular_ports.length() + test_graph.unconnected_ports.length() {
    abort("unexpected number of visible ports after hiding")
  }
  self_loop_preprocessor_test_assert_node_contains_ports(
    test_graph.self_loop_node,
    test_graph.regular_ports,
  )
  self_loop_preprocessor_test_assert_node_contains_ports(
    test_graph.self_loop_node,
    test_graph.unconnected_ports,
  )

  self_loop_preprocessor_test_assert_hidden_edges(test_graph)
}

///|
fn self_loop_preprocessor_test_ports_untouched(
  constraints : PortConstraints,
) -> Unit {
  let test_graph = self_loop_preprocessor_test_new_graph(constraints)
  let processor = new_self_loop_pre_processor_layout_processor()
  processor.process(test_graph.test_graph, Some(new_null_elk_progress_monitor()))

  if test_graph.self_loop_node.get_ports().length() !=
    test_graph.regular_ports.length() +
      test_graph.only_self_loop_ports.length() +
      test_graph.unconnected_ports.length() {
    abort("port count changed although constraints fix port order")
  }

  self_loop_preprocessor_test_assert_hidden_edges(test_graph)
}

///|
fn self_loop_preprocessor_test_port_constraints(name : String) -> PortConstraints {
  for constraints in port_constraints_values() {
    if port_constraints_to_string(constraints) == name {
      return constraints
    }
  }
  abort("unknown port constraints")
}

///|
test "self loop preprocessor hides pure self loop ports for FREE constraints" {
  self_loop_preprocessor_test_ports_hidden(
    self_loop_preprocessor_test_port_constraints("FREE"),
  )
}

///|
test "self loop preprocessor hides pure self loop ports for FIXED_SIDE constraints" {
  self_loop_preprocessor_test_ports_hidden(
    self_loop_preprocessor_test_port_constraints("FIXED_SIDE"),
  )
}

///|
test "self loop preprocessor keeps ports for FIXED_ORDER constraints" {
  self_loop_preprocessor_test_ports_untouched(
    self_loop_preprocessor_test_port_constraints("FIXED_ORDER"),
  )
}

///|
test "self loop preprocessor keeps ports for FIXED_RATIO constraints" {
  self_loop_preprocessor_test_ports_untouched(
    self_loop_preprocessor_test_port_constraints("FIXED_RATIO"),
  )
}

///|
test "self loop preprocessor keeps ports for FIXED_POS constraints" {
  self_loop_preprocessor_test_ports_untouched(
    self_loop_preprocessor_test_port_constraints("FIXED_POS"),
  )
}
