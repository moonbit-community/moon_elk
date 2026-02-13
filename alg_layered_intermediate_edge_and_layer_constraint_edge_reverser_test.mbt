///|
fn lport_internal_handle(port : LPort) -> Int {
  port.get_handle()
}

///|
fn edge_and_layer_constraint_edge_reverser_test_port_side(
  name : String,
) -> PortSide {
  for side in port_side_values() {
    if port_side_to_string(side) == name {
      return side
    }
  }
  abort("unknown port side")
}

///|
fn edge_and_layer_constraint_edge_reverser_test_new_node(
  graph : LGraph,
  layer_constraint : String,
) -> LNode {
  let node = new_l_node(graph=Some(graph))
  node.set_property_string(
    layered_options_layering_layer_constraint, layer_constraint,
  )
  graph.get_layerless_nodes().push(node)
  node
}

///|
fn edge_and_layer_constraint_edge_reverser_test_new_port(
  node : LNode,
  side : String,
) -> LPort {
  let port = new_l_port()
  port.set_side(edge_and_layer_constraint_edge_reverser_test_port_side(side))
  port.set_node(Some(node))
  port
}

///|
fn edge_and_layer_constraint_edge_reverser_test_new_edge(
  source : LPort,
  target : LPort,
) -> LEdge {
  let edge = new_l_edge()
  edge.set_source(Some(source))
  edge.set_target(Some(target))
  edge
}

///|
fn edge_and_layer_constraint_edge_reverser_test_require_source(
  edge : LEdge,
) -> LPort {
  match edge.get_source() {
    Some(value) => value
    None => abort("edge has no source")
  }
}

///|
fn edge_and_layer_constraint_edge_reverser_test_require_target(
  edge : LEdge,
) -> LPort {
  match edge.get_target() {
    Some(value) => value
    None => abort("edge has no target")
  }
}

///|
fn edge_and_layer_constraint_edge_reverser_test_require_node(
  port : LPort,
) -> LNode {
  match port.get_node() {
    Some(value) => value
    None => abort("port has no owner")
  }
}

///|
fn edge_and_layer_constraint_edge_reverser_test_constraint(
  node : LNode,
) -> LayerConstraint {
  layer_constraint_from_string(
    node.get_property_string(layered_options_layering_layer_constraint),
  )
}

///|
test "edge and layer constraint edge reverser reports expected task name" {
  let processor = new_edge_and_layer_constraint_edge_reverser_layout_processor()
  let monitor = new_elk_progress_monitor()
  processor.process(new_l_graph(), Some(monitor))
  inspect(
    monitor.get_task_name(),
    content="Edge and layer constraint edge reversal",
  )
}

///|
test "edge and layer constraint edge reverser enforces outer-node direction rules" {
  let graph = new_l_graph()
  let processor = new_edge_and_layer_constraint_edge_reverser_layout_processor()

  let first_separate = edge_and_layer_constraint_edge_reverser_test_new_node(
    graph, "FIRST_SEPARATE",
  )
  let first = edge_and_layer_constraint_edge_reverser_test_new_node(
    graph, "FIRST",
  )
  let middle = edge_and_layer_constraint_edge_reverser_test_new_node(
    graph, "NONE",
  )
  let last = edge_and_layer_constraint_edge_reverser_test_new_node(
    graph, "LAST",
  )
  let last_separate = edge_and_layer_constraint_edge_reverser_test_new_node(
    graph, "LAST_SEPARATE",
  )

  let first_separate_east = edge_and_layer_constraint_edge_reverser_test_new_port(
    first_separate, "EAST",
  )
  let first_west = edge_and_layer_constraint_edge_reverser_test_new_port(
    first, "WEST",
  )
  let middle_east = edge_and_layer_constraint_edge_reverser_test_new_port(
    middle, "EAST",
  )
  let middle_west = edge_and_layer_constraint_edge_reverser_test_new_port(
    middle, "WEST",
  )
  let last_east = edge_and_layer_constraint_edge_reverser_test_new_port(
    last, "EAST",
  )
  let first_separate_west = edge_and_layer_constraint_edge_reverser_test_new_port(
    first_separate, "WEST",
  )
  let last_separate_west = edge_and_layer_constraint_edge_reverser_test_new_port(
    last_separate, "WEST",
  )
  let last_separate_east = edge_and_layer_constraint_edge_reverser_test_new_port(
    last_separate, "EAST",
  )

  let incoming_from_first_separate = edge_and_layer_constraint_edge_reverser_test_new_edge(
    first_separate_east, first_west,
  )
  let incoming_bad = edge_and_layer_constraint_edge_reverser_test_new_edge(
    middle_east, first_west,
  )
  let outgoing_bad = edge_and_layer_constraint_edge_reverser_test_new_edge(
    last_east, middle_west,
  )
  let outgoing_to_last_separate = edge_and_layer_constraint_edge_reverser_test_new_edge(
    last_east, last_separate_west,
  )
  let first_separate_incoming_bad = edge_and_layer_constraint_edge_reverser_test_new_edge(
    middle_east, first_separate_west,
  )
  let last_separate_outgoing_bad = edge_and_layer_constraint_edge_reverser_test_new_edge(
    last_separate_east, middle_west,
  )

  processor.process(graph, None)

  assert_eq(
    lport_internal_handle(
      edge_and_layer_constraint_edge_reverser_test_require_source(
        incoming_from_first_separate,
      ),
    ),
    lport_internal_handle(first_separate_east),
  )
  assert_eq(
    lport_internal_handle(
      edge_and_layer_constraint_edge_reverser_test_require_target(
        incoming_from_first_separate,
      ),
    ),
    lport_internal_handle(first_west),
  )

  assert_eq(
    lport_internal_handle(
      edge_and_layer_constraint_edge_reverser_test_require_source(incoming_bad),
    ),
    lport_internal_handle(first_west),
  )
  assert_eq(
    lport_internal_handle(
      edge_and_layer_constraint_edge_reverser_test_require_target(incoming_bad),
    ),
    lport_internal_handle(middle_east),
  )
  assert_true(incoming_bad.get_property_bool(internal_properties_reversed))

  assert_eq(
    lport_internal_handle(
      edge_and_layer_constraint_edge_reverser_test_require_source(outgoing_bad),
    ),
    lport_internal_handle(middle_west),
  )
  assert_eq(
    lport_internal_handle(
      edge_and_layer_constraint_edge_reverser_test_require_target(outgoing_bad),
    ),
    lport_internal_handle(last_east),
  )
  assert_true(outgoing_bad.get_property_bool(internal_properties_reversed))

  assert_eq(
    lport_internal_handle(
      edge_and_layer_constraint_edge_reverser_test_require_source(
        outgoing_to_last_separate,
      ),
    ),
    lport_internal_handle(last_east),
  )
  assert_eq(
    lport_internal_handle(
      edge_and_layer_constraint_edge_reverser_test_require_target(
        outgoing_to_last_separate,
      ),
    ),
    lport_internal_handle(last_separate_west),
  )
  assert_false(
    outgoing_to_last_separate.get_property_bool(internal_properties_reversed),
  )

  assert_eq(
    lport_internal_handle(
      edge_and_layer_constraint_edge_reverser_test_require_source(
        first_separate_incoming_bad,
      ),
    ),
    lport_internal_handle(first_separate_west),
  )
  assert_eq(
    lport_internal_handle(
      edge_and_layer_constraint_edge_reverser_test_require_target(
        first_separate_incoming_bad,
      ),
    ),
    lport_internal_handle(middle_east),
  )

  assert_eq(
    lport_internal_handle(
      edge_and_layer_constraint_edge_reverser_test_require_source(
        last_separate_outgoing_bad,
      ),
    ),
    lport_internal_handle(middle_west),
  )
  assert_eq(
    lport_internal_handle(
      edge_and_layer_constraint_edge_reverser_test_require_target(
        last_separate_outgoing_bad,
      ),
    ),
    lport_internal_handle(last_separate_east),
  )

  for incoming in first.get_incoming_edges() {
    let source_node = edge_and_layer_constraint_edge_reverser_test_require_node(
      edge_and_layer_constraint_edge_reverser_test_require_source(incoming),
    )
    assert_eq(
      layer_constraint_to_string(
        edge_and_layer_constraint_edge_reverser_test_constraint(source_node),
      ),
      "FIRST_SEPARATE",
    )
  }

  for outgoing in last.get_outgoing_edges() {
    let target_node = edge_and_layer_constraint_edge_reverser_test_require_node(
      edge_and_layer_constraint_edge_reverser_test_require_target(outgoing),
    )
    assert_eq(
      layer_constraint_to_string(
        edge_and_layer_constraint_edge_reverser_test_constraint(target_node),
      ),
      "LAST_SEPARATE",
    )
  }

  assert_true(first_separate.get_incoming_edges().is_empty())
  assert_true(last_separate.get_outgoing_edges().is_empty())
}

///|
test "edge and layer constraint edge reverser handles all-ports-reversed inner nodes" {
  let graph = new_l_graph()
  let processor = new_edge_and_layer_constraint_edge_reverser_layout_processor()

  let source = edge_and_layer_constraint_edge_reverser_test_new_node(
    graph, "NONE",
  )
  let odd = edge_and_layer_constraint_edge_reverser_test_new_node(graph, "NONE")
  odd.set_property_string(port_constraints, "FIXED_SIDE")

  let source_east = edge_and_layer_constraint_edge_reverser_test_new_port(
    source, "EAST",
  )
  let odd_east = edge_and_layer_constraint_edge_reverser_test_new_port(
    odd, "EAST",
  )
  let edge = edge_and_layer_constraint_edge_reverser_test_new_edge(
    source_east, odd_east,
  )

  processor.process(graph, None)

  assert_eq(
    lport_internal_handle(
      edge_and_layer_constraint_edge_reverser_test_require_source(edge),
    ),
    lport_internal_handle(odd_east),
  )
  assert_eq(
    lport_internal_handle(
      edge_and_layer_constraint_edge_reverser_test_require_target(edge),
    ),
    lport_internal_handle(source_east),
  )
  assert_true(edge.get_property_bool(internal_properties_reversed))
}

///|
test "edge and layer constraint edge reverser keeps inner-node edges when FIRST/FIRST_SEPARATE would be violated" {
  let graph = new_l_graph()
  let processor = new_edge_and_layer_constraint_edge_reverser_layout_processor()

  let source_first = edge_and_layer_constraint_edge_reverser_test_new_node(
    graph, "FIRST",
  )
  let odd = edge_and_layer_constraint_edge_reverser_test_new_node(graph, "NONE")
  odd.set_property_string(port_constraints, "FIXED_SIDE")

  let source_east = edge_and_layer_constraint_edge_reverser_test_new_port(
    source_first, "EAST",
  )
  let odd_east = edge_and_layer_constraint_edge_reverser_test_new_port(
    odd, "EAST",
  )
  let edge = edge_and_layer_constraint_edge_reverser_test_new_edge(
    source_east, odd_east,
  )

  processor.process(graph, None)

  assert_eq(
    lport_internal_handle(
      edge_and_layer_constraint_edge_reverser_test_require_source(edge),
    ),
    lport_internal_handle(source_east),
  )
  assert_eq(
    lport_internal_handle(
      edge_and_layer_constraint_edge_reverser_test_require_target(edge),
    ),
    lport_internal_handle(odd_east),
  )
  assert_false(edge.get_property_bool(internal_properties_reversed))
}
