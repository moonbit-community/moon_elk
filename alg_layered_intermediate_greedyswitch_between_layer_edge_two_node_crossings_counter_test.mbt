///|
fn between_layer_bb_port_side_west() -> PortSide {
  port_side_values()[4]
}

///|
fn between_layer_bb_port_side_east() -> PortSide {
  port_side_values()[2]
}

///|
fn between_layer_bb_new_node(layer : Layer) -> LNode {
  let node = new_l_node()
  node.set_layer(Some(layer))
  node
}

///|
fn between_layer_bb_add_port(node : LNode, side : PortSide) -> LPort {
  let port = new_l_port()
  port.set_side(side)
  port.set_node(Some(node))
  port
}

///|
fn between_layer_bb_connect_to_target_port(
  source : LNode,
  target_port : LPort,
) -> LPort {
  let source_port = between_layer_bb_add_port(
    source,
    between_layer_bb_port_side_east(),
  )
  let edge = new_l_edge()
  edge.set_source(Some(source_port))
  edge.set_target(Some(target_port))
  source_port
}

///|
test "BetweenLayerEdgeTwoNodeCrossingsCounter returns zero for disconnected nodes" {
  let graph = new_l_graph()
  let layer = new_layer(graph)
  graph.get_layers().push(layer)

  let upper = between_layer_bb_new_node(layer)
  let lower = between_layer_bb_new_node(layer)
  let order = [[upper, lower]]
  let counter = new_between_layer_edge_two_node_crossings_counter(order, 0)

  counter.count_both_side_crossings(upper, lower)
  assert_eq(counter.get_upper_lower_crossings(), 0)
  assert_eq(counter.get_lower_upper_crossings(), 0)

  counter.count_eastern_edge_crossings(upper, lower)
  assert_eq(counter.get_upper_lower_crossings(), 0)
  assert_eq(counter.get_lower_upper_crossings(), 0)

  counter.count_western_edge_crossings(upper, lower)
  assert_eq(counter.get_upper_lower_crossings(), 0)
  assert_eq(counter.get_lower_upper_crossings(), 0)
}

///|
test "BetweenLayerEdgeTwoNodeCrossingsCounter counts simple west-side crossing" {
  let graph = new_l_graph()
  let left_layer = new_layer(graph)
  let right_layer = new_layer(graph)
  graph.get_layers().push(left_layer)
  graph.get_layers().push(right_layer)

  let left_top = between_layer_bb_new_node(left_layer)
  let left_bottom = between_layer_bb_new_node(left_layer)
  let right_top = between_layer_bb_new_node(right_layer)
  let right_bottom = between_layer_bb_new_node(right_layer)

  let right_top_port = between_layer_bb_add_port(
    right_top,
    between_layer_bb_port_side_west(),
  )
  let right_bottom_port = between_layer_bb_add_port(
    right_bottom,
    between_layer_bb_port_side_west(),
  )

  ignore(between_layer_bb_connect_to_target_port(left_top, right_bottom_port))
  ignore(between_layer_bb_connect_to_target_port(left_bottom, right_top_port))

  let order = [[left_top, left_bottom], [right_top, right_bottom]]
  let counter = new_between_layer_edge_two_node_crossings_counter(order, 1)

  counter.count_western_edge_crossings(right_top, right_bottom)
  assert_eq(counter.get_upper_lower_crossings(), 1)
  assert_eq(counter.get_lower_upper_crossings(), 0)

  counter.count_both_side_crossings(right_top, right_bottom)
  assert_eq(counter.get_upper_lower_crossings(), 1)
  assert_eq(counter.get_lower_upper_crossings(), 0)
}

///|
test "BetweenLayerEdgeTwoNodeCrossingsCounter keeps shared target port crossing-free" {
  let graph = new_l_graph()
  let left_layer = new_layer(graph)
  let right_layer = new_layer(graph)
  graph.get_layers().push(left_layer)
  graph.get_layers().push(right_layer)

  let left_top = between_layer_bb_new_node(left_layer)
  let left_bottom = between_layer_bb_new_node(left_layer)
  let right = between_layer_bb_new_node(right_layer)
  let right_port = between_layer_bb_add_port(
    right,
    between_layer_bb_port_side_west(),
  )

  ignore(between_layer_bb_connect_to_target_port(left_top, right_port))
  ignore(between_layer_bb_connect_to_target_port(left_top, right_port))
  ignore(between_layer_bb_connect_to_target_port(left_bottom, right_port))

  let order = [[left_top, left_bottom], [right]]
  let counter = new_between_layer_edge_two_node_crossings_counter(order, 0)
  counter.count_eastern_edge_crossings(left_top, left_bottom)

  assert_eq(counter.get_upper_lower_crossings(), 0)
  assert_eq(counter.get_lower_upper_crossings(), 0)
}
