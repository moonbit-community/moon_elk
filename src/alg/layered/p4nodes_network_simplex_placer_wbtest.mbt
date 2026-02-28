///|
fn network_simplex_wbtest_port_side(name : String) -> @core.PortSide {
  for side in @core.port_side_values() {
    if @core.port_side_to_string(side) == name {
      return side
    }
  }
  abort("unknown port side")
}

///|
fn network_simplex_wbtest_add_layer(graph : LGraph) -> Layer {
  let layer = new_layer(graph)
  graph.get_layers().push(layer)
  layer
}

///|
fn network_simplex_wbtest_add_basic_node(layer : Layer) -> LNode {
  let node = new_l_node()
  node.set_layer(Some(layer))
  ignore(node.get_size().set_xy(10.0, 10.0))
  node
}

///|
fn network_simplex_wbtest_add_port(
  node : LNode,
  side : @core.PortSide,
) -> LPort {
  let port = new_l_port()
  port.set_node(Some(node))
  port.set_side(side)
  port
}

///|
test "network simplex crossing marker keeps first open edge unmarked on unmatched close" {
  let graph = new_l_graph()
  let left = network_simplex_wbtest_add_layer(graph)
  let right = network_simplex_wbtest_add_layer(graph)

  let source = network_simplex_wbtest_add_basic_node(left)
  let open_target = network_simplex_wbtest_add_basic_node(right)
  let unmatched_target = network_simplex_wbtest_add_basic_node(right)

  let source_east = network_simplex_wbtest_add_port(
    source,
    network_simplex_wbtest_port_side("EAST"),
  )
  let source_west = network_simplex_wbtest_add_port(
    source,
    network_simplex_wbtest_port_side("WEST"),
  )
  let open_target_west = network_simplex_wbtest_add_port(
    open_target,
    network_simplex_wbtest_port_side("WEST"),
  )
  let unmatched_target_west = network_simplex_wbtest_add_port(
    unmatched_target,
    network_simplex_wbtest_port_side("WEST"),
  )

  let open_edge = new_l_edge()
  open_edge.set_source(Some(source_east))
  open_edge.set_target(Some(open_target_west))

  let unmatched_close_edge = new_l_edge()
  unmatched_close_edge.set_source(Some(source_west))
  unmatched_close_edge.set_target(Some(unmatched_target_west))

  let (node_count, edge_count) = network_simplex_prepare(graph)
  let state = network_simplex_new_auxiliary_state(graph, node_count, edge_count)
  network_simplex_build_initial_auxiliary_graph(graph, state)
  network_simplex_mark_edge_crossings(graph, state)

  assert_false(state.crossing[open_edge.get_id()])
  assert_false(state.crossing[unmatched_close_edge.get_id()])
}

///|
test "network simplex crossing marker follows Java hasPrevious boundary with two opens" {
  let graph = new_l_graph()
  let left = network_simplex_wbtest_add_layer(graph)
  let right = network_simplex_wbtest_add_layer(graph)

  let left_bottom = network_simplex_wbtest_add_basic_node(left)
  let left_top = network_simplex_wbtest_add_basic_node(left)
  let right_top = network_simplex_wbtest_add_basic_node(right)
  let right_bottom = network_simplex_wbtest_add_basic_node(right)

  let left_bottom_east = network_simplex_wbtest_add_port(
    left_bottom,
    network_simplex_wbtest_port_side("EAST"),
  )
  let left_top_east = network_simplex_wbtest_add_port(
    left_top,
    network_simplex_wbtest_port_side("EAST"),
  )
  let left_top_west = network_simplex_wbtest_add_port(
    left_top,
    network_simplex_wbtest_port_side("WEST"),
  )
  let right_top_west = network_simplex_wbtest_add_port(
    right_top,
    network_simplex_wbtest_port_side("WEST"),
  )
  let right_bottom_west = network_simplex_wbtest_add_port(
    right_bottom,
    network_simplex_wbtest_port_side("WEST"),
  )

  // Create in this order so right_top incoming order is [second_open_edge, first_open_edge].
  let second_open_edge = new_l_edge()
  second_open_edge.set_source(Some(left_top_east))
  second_open_edge.set_target(Some(right_top_west))

  let first_open_edge = new_l_edge()
  first_open_edge.set_source(Some(left_bottom_east))
  first_open_edge.set_target(Some(right_top_west))

  let unmatched_close_edge = new_l_edge()
  unmatched_close_edge.set_source(Some(left_top_west))
  unmatched_close_edge.set_target(Some(right_bottom_west))

  let (node_count, edge_count) = network_simplex_prepare(graph)
  let state = network_simplex_new_auxiliary_state(graph, node_count, edge_count)
  network_simplex_build_initial_auxiliary_graph(graph, state)
  network_simplex_mark_edge_crossings(graph, state)

  assert_false(state.crossing[first_open_edge.get_id()])
  assert_true(state.crossing[second_open_edge.get_id()])
  assert_true(state.crossing[unmatched_close_edge.get_id()])
}
