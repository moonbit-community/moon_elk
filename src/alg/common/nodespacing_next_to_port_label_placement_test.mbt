///|
fn next_to_port_should_label_be_placed_next_to_port(
  port : ElkPort,
  inside_label_placement : Bool,
) -> Bool {
  if port_incoming_edges(port).is_empty() &&
    port_outgoing_edges(port).is_empty() {
    return true
  }

  let parent = match port_parent(port) {
    Some(node) => node
    None => return false
  }

  let mut edges_to_insides = false
  let mut edges_to_somewhere_else = false

  for out_edge in port_outgoing_edges(port) {
    let targets = edge_targets(out_edge)
    if !targets.is_empty() {
      let inside_edge = is_descendant(
        connectable_shape_to_node(Some(targets[0])),
        parent,
      )
      edges_to_insides = edges_to_insides || inside_edge
      edges_to_somewhere_else = edges_to_somewhere_else || !inside_edge
    }
  }

  for in_edge in port_incoming_edges(port) {
    let sources = edge_sources(in_edge)
    if !sources.is_empty() {
      let inside_edge = is_descendant(
        connectable_shape_to_node(Some(sources[0])),
        parent,
      )
      edges_to_insides = edges_to_insides || inside_edge
      edges_to_somewhere_else = edges_to_somewhere_else || !inside_edge
    }
  }

  (inside_label_placement && !edges_to_insides) ||
  (!inside_label_placement && !edges_to_somewhere_else)
}

///|
fn next_to_port_fixture() -> (ElkNode, ElkNode, ElkNode, ElkPort) {
  reset_graph_model_for_test()
  let root = create_graph()
  let parent = create_node(Some(root))
  let descendant = create_node(Some(parent))
  let outside = create_node(Some(root))
  let port = create_port(Some(parent))
  (parent, descendant, outside, port)
}

///|
fn next_to_port_connect(port : ElkPort, target : ElkNode) -> Unit {
  let edge = create_edge(None)
  edge_add_source(edge, make_port_shape(port))
  edge_add_target(edge, make_node_shape(target))
}

///|
fn next_to_port_connect_incoming(source : ElkNode, port : ElkPort) -> Unit {
  let edge = create_edge(None)
  edge_add_source(edge, make_node_shape(source))
  edge_add_target(edge, make_port_shape(port))
}

///|
test "NextToPortLabelPlacement no incident edge allows next-to-port" {
  let (_, _, _, port) = next_to_port_fixture()
  assert_true(next_to_port_should_label_be_placed_next_to_port(port, true))
  assert_true(next_to_port_should_label_be_placed_next_to_port(port, false))
}

///|
test "NextToPortLabelPlacement inside placement with inside edge is false" {
  let (_, descendant, _, port) = next_to_port_fixture()
  next_to_port_connect(port, descendant)
  assert_false(next_to_port_should_label_be_placed_next_to_port(port, true))
}

///|
test "NextToPortLabelPlacement inside placement with outside edge is true" {
  let (_, _, outside, port) = next_to_port_fixture()
  next_to_port_connect(port, outside)
  assert_true(next_to_port_should_label_be_placed_next_to_port(port, true))
}

///|
test "NextToPortLabelPlacement outside placement with outside edge is false" {
  let (_, _, outside, port) = next_to_port_fixture()
  next_to_port_connect(port, outside)
  assert_false(next_to_port_should_label_be_placed_next_to_port(port, false))
}

///|
test "NextToPortLabelPlacement outside placement with inside incoming is true" {
  let (_, descendant, _, port) = next_to_port_fixture()
  next_to_port_connect_incoming(descendant, port)
  assert_true(next_to_port_should_label_be_placed_next_to_port(port, false))
}
