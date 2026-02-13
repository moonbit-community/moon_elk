///|
fn switch_decider_bb_node_type_normal() -> NodeType {
  node_type_values()[0]
}

///|
fn switch_decider_bb_node_type_north_south_port() -> NodeType {
  node_type_values()[3]
}

///|
fn switch_decider_bb_port_side_east() -> PortSide {
  port_side_values()[2]
}

///|
fn switch_decider_bb_port_side_west() -> PortSide {
  port_side_values()[4]
}

///|
fn switch_decider_bb_greedy_one_sided() -> GreedySwitchType {
  greedy_switch_type_values()[0]
}

///|
fn switch_decider_bb_crossing_west() -> CrossingCountSide {
  crossing_count_side_values()[0]
}

///|
fn switch_decider_bb_new_node(
  layer : Layer,
  id : Int,
  node_type : NodeType,
) -> LNode {
  let node = new_l_node()
  node.set_layer(Some(layer))
  node.set_id(id)
  node.set_type(node_type)
  node
}

///|
fn switch_decider_bb_new_port(node : LNode, side : PortSide, id : Int) -> LPort {
  let port = new_l_port()
  port.set_node(Some(node))
  port.set_side(side)
  port.set_id(id)
  port
}

///|
fn switch_decider_bb_connect(source : LPort, target : LPort) -> Unit {
  let edge = new_l_edge()
  edge.set_source(Some(source))
  edge.set_target(Some(target))
}

///|
fn switch_decider_bb_port_count(node_order : Array[Array[LNode]]) -> Int {
  let mut count = 0
  for layer in node_order {
    for node in layer {
      count = count + node.get_ports().length()
    }
  }
  count
}

///|
fn switch_decider_bb_cross_graph() -> (Array[Array[LNode]], LNode, LNode) {
  let graph = new_l_graph()
  let left_layer = new_layer(graph)
  let right_layer = new_layer(graph)
  graph.get_layers().push(left_layer)
  graph.get_layers().push(right_layer)

  let left_upper = switch_decider_bb_new_node(
    left_layer,
    0,
    switch_decider_bb_node_type_normal(),
  )
  let left_lower = switch_decider_bb_new_node(
    left_layer,
    1,
    switch_decider_bb_node_type_normal(),
  )
  let right_upper = switch_decider_bb_new_node(
    right_layer,
    0,
    switch_decider_bb_node_type_normal(),
  )
  let right_lower = switch_decider_bb_new_node(
    right_layer,
    1,
    switch_decider_bb_node_type_normal(),
  )

  let left_upper_port = switch_decider_bb_new_port(
    left_upper,
    switch_decider_bb_port_side_east(),
    0,
  )
  let left_lower_port = switch_decider_bb_new_port(
    left_lower,
    switch_decider_bb_port_side_east(),
    1,
  )
  let right_upper_port = switch_decider_bb_new_port(
    right_upper,
    switch_decider_bb_port_side_west(),
    2,
  )
  let right_lower_port = switch_decider_bb_new_port(
    right_lower,
    switch_decider_bb_port_side_west(),
    3,
  )

  switch_decider_bb_connect(left_upper_port, right_lower_port)
  switch_decider_bb_connect(left_lower_port, right_upper_port)

  (
    [[left_upper, left_lower], [right_upper, right_lower]],
    right_upper,
    right_lower,
  )
}

///|
test "SwitchDecider reports switch reduces crossings on crossed layer" {
  let (node_order, right_upper, right_lower) = switch_decider_bb_cross_graph()
  ignore((right_upper, right_lower))
  let filler = new_crossing_matrix_filler(
    switch_decider_bb_greedy_one_sided(),
    node_order,
    1,
    switch_decider_bb_crossing_west(),
  )
  let graph_data = new_graph_info_holder(node_order)
  let decider = new_switch_decider(
    1,
    node_order,
    filler,
    Array::make(switch_decider_bb_port_count(node_order), 0),
    graph_data,
    true,
  )

  assert_true(decider.does_switch_reduce_crossings(0, 1))
}

///|
test "SwitchDecider successor constraint prevents switching" {
  let (node_order, right_upper, right_lower) = switch_decider_bb_cross_graph()
  right_upper.set_property_l_node_array(
    internal_properties_in_layer_successor_constraints,
    [right_lower],
  )

  let filler = new_crossing_matrix_filler(
    switch_decider_bb_greedy_one_sided(),
    node_order,
    1,
    switch_decider_bb_crossing_west(),
  )
  let graph_data = new_graph_info_holder(node_order)
  let decider = new_switch_decider(
    1,
    node_order,
    filler,
    Array::make(switch_decider_bb_port_count(node_order), 0),
    graph_data,
    true,
  )

  assert_false(decider.does_switch_reduce_crossings(0, 1))
}

///|
test "SwitchDecider blocks normal and north-south dummy swaps" {
  let graph = new_l_graph()
  let layer = new_layer(graph)
  graph.get_layers().push(layer)

  let normal = switch_decider_bb_new_node(
    layer,
    0,
    switch_decider_bb_node_type_normal(),
  )
  let ns_dummy = switch_decider_bb_new_node(
    layer,
    1,
    switch_decider_bb_node_type_north_south_port(),
  )

  let node_order = [[normal, ns_dummy]]
  let filler = new_crossing_matrix_filler(
    switch_decider_bb_greedy_one_sided(),
    node_order,
    0,
    switch_decider_bb_crossing_west(),
  )
  let graph_data = new_graph_info_holder(node_order)
  let decider = new_switch_decider(
    0,
    node_order,
    filler,
    Array::make(0, 0),
    graph_data,
    true,
  )

  assert_false(decider.does_switch_reduce_crossings(0, 1))
}
