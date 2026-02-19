///|
fn reversed_edge_restorer_test_port_side_equals(
  left : @core.PortSide,
  right : @core.PortSide,
) -> Bool {
  @core.port_side_to_string(left) == @core.port_side_to_string(right)
}

///|
fn reversed_edge_restorer_test_west() -> @core.PortSide {
  @core.port_side_values()[4]
}

///|
fn reversed_edge_restorer_test_east() -> @core.PortSide {
  @core.port_side_values()[2]
}

///|
fn reversed_edge_restorer_test_add_node(graph : LGraph) -> LNode {
  let node = new_l_node(graph=Some(graph))
  graph.get_layerless_nodes().push(node)
  let input = new_l_port()
  input.set_side(reversed_edge_restorer_test_west())
  input.set_node(Some(node))
  node.add_port(input)
  let output = new_l_port()
  output.set_side(reversed_edge_restorer_test_east())
  output.set_node(Some(node))
  node.add_port(output)
  node
}

///|
fn reversed_edge_restorer_test_input_port(node : LNode) -> LPort {
  for port in node.get_ports() {
    if reversed_edge_restorer_test_port_side_equals(
        port.get_side(),
        reversed_edge_restorer_test_west(),
      ) {
      return port
    }
  }
  abort("input port missing")
}

///|
fn reversed_edge_restorer_test_output_port(node : LNode) -> LPort {
  for port in node.get_ports() {
    if reversed_edge_restorer_test_port_side_equals(
        port.get_side(),
        reversed_edge_restorer_test_east(),
      ) {
      return port
    }
  }
  abort("output port missing")
}

///|
fn reversed_edge_restorer_test_connect(source : LNode, target : LNode) -> LEdge {
  let edge = new_l_edge()
  edge.set_source(Some(reversed_edge_restorer_test_output_port(source)))
  edge.set_target(Some(reversed_edge_restorer_test_input_port(target)))
  edge
}

///|
fn reversed_edge_restorer_test_target_node(edge : LEdge) -> LNode? {
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
fn reversed_edge_restorer_test_find_edge(
  source : LNode,
  target : LNode,
) -> LEdge? {
  for edge in source.get_outgoing_edges() {
    match reversed_edge_restorer_test_target_node(edge) {
      Some(node) =>
        if node.get_handle() == target.get_handle() {
          return Some(edge)
        }
      None => ()
    }
  }
  None
}

///|
fn reversed_edge_restorer_test_reverse_like_cycle_breaking(
  edge : LEdge,
) -> Unit {
  let old_source = edge.get_source()
  let old_target = edge.get_target()
  edge.set_source(None)
  edge.set_target(None)
  edge.set_source(old_target)
  edge.set_target(old_source)
  edge.set_property_bool(
    internal_properties_reversed,
    !edge.get_property_bool(internal_properties_reversed),
  )
}

///|
test "ReversedEdgeRestorer restores reversed edge @core.direction and flag" {
  let graph = new_l_graph()
  let layer = new_layer(graph)
  graph.get_layers().push(layer)

  let source = reversed_edge_restorer_test_add_node(graph)
  let target = reversed_edge_restorer_test_add_node(graph)
  source.set_layer(Some(layer))
  target.set_layer(Some(layer))

  let edge = reversed_edge_restorer_test_connect(source, target)
  assert_eq(
    match reversed_edge_restorer_test_find_edge(source, target) {
      Some(_) => true
      None => false
    },
    true,
  )

  reversed_edge_restorer_test_reverse_like_cycle_breaking(edge)
  assert_eq(
    match reversed_edge_restorer_test_find_edge(target, source) {
      Some(_) => true
      None => false
    },
    true,
  )
  assert_eq(edge.get_property_bool(internal_properties_reversed), true)

  let processor = new_reversed_edge_restorer_layout_processor()
  processor.process(graph, None)

  assert_eq(
    match reversed_edge_restorer_test_find_edge(source, target) {
      Some(_) => true
      None => false
    },
    true,
  )
  assert_eq(
    match reversed_edge_restorer_test_find_edge(target, source) {
      Some(_) => true
      None => false
    },
    false,
  )
  assert_eq(edge.get_property_bool(internal_properties_reversed), false)
}
