///|
fn in_layer_counter_bb_port_side_east() -> PortSide {
  port_side_values()[2]
}

///|
fn in_layer_counter_bb_port_side_west() -> PortSide {
  port_side_values()[4]
}

///|
fn in_layer_counter_bb_new_node(layer : Layer, id : Int) -> LNode {
  let node = new_l_node()
  node.set_layer(Some(layer))
  node.set_id(id)
  node
}

///|
fn in_layer_counter_bb_new_port(
  node : LNode,
  side : PortSide,
  id : Int,
) -> LPort {
  let port = new_l_port()
  port.set_node(Some(node))
  port.set_side(side)
  port.set_id(id)
  port
}

///|
fn in_layer_counter_bb_connect(source : LPort, target : LPort) -> Unit {
  let edge = new_l_edge()
  edge.set_source(Some(source))
  edge.set_target(Some(target))
}

///|
fn in_layer_counter_bb_pair_value(value : Int?) -> Int {
  match value {
    Some(v) => v
    None => 0
  }
}

///|
test "InLayerEdgeTwoNodeCrossingCounter ignores pure between-layer edges" {
  let graph = new_l_graph()
  let left_layer = new_layer(graph)
  let right_layer = new_layer(graph)
  graph.get_layers().push(left_layer)
  graph.get_layers().push(right_layer)

  let left_upper = in_layer_counter_bb_new_node(left_layer, 0)
  let left_lower = in_layer_counter_bb_new_node(left_layer, 1)
  let right_upper = in_layer_counter_bb_new_node(right_layer, 0)
  let right_lower = in_layer_counter_bb_new_node(right_layer, 1)

  let left_upper_port = in_layer_counter_bb_new_port(
    left_upper,
    in_layer_counter_bb_port_side_east(),
    0,
  )
  let left_lower_port = in_layer_counter_bb_new_port(
    left_lower,
    in_layer_counter_bb_port_side_east(),
    1,
  )
  let right_upper_port = in_layer_counter_bb_new_port(
    right_upper,
    in_layer_counter_bb_port_side_west(),
    2,
  )
  let right_lower_port = in_layer_counter_bb_new_port(
    right_lower,
    in_layer_counter_bb_port_side_west(),
    3,
  )

  in_layer_counter_bb_connect(left_upper_port, right_lower_port)
  in_layer_counter_bb_connect(left_lower_port, right_upper_port)

  let left_counter = new_crossings_counter(Array::make(4, 0))
  let right_counter = new_crossings_counter(Array::make(4, 0))
  ignore(
    left_counter.init_port_positions_for_in_layer_crossings(
      [left_upper, left_lower],
      in_layer_counter_bb_port_side_west(),
    ),
  )
  ignore(
    right_counter.init_port_positions_for_in_layer_crossings(
      [left_upper, left_lower],
      in_layer_counter_bb_port_side_east(),
    ),
  )

  let left_crossings = left_counter.count_in_layer_crossings_between_nodes_in_both_orders(
    left_upper,
    left_lower,
    in_layer_counter_bb_port_side_west(),
  )
  let right_crossings = right_counter.count_in_layer_crossings_between_nodes_in_both_orders(
    left_upper,
    left_lower,
    in_layer_counter_bb_port_side_east(),
  )

  let upper_lower = in_layer_counter_bb_pair_value(left_crossings.get_first()) +
    in_layer_counter_bb_pair_value(right_crossings.get_first())
  let lower_upper = in_layer_counter_bb_pair_value(left_crossings.get_second()) +
    in_layer_counter_bb_pair_value(right_crossings.get_second())

  assert_eq(upper_lower, 0)
  assert_eq(lower_upper, 0)
}

///|
test "InLayerEdgeTwoNodeCrossingCounter updates counts after switch" {
  let graph = new_l_graph()
  let layer = new_layer(graph)
  graph.get_layers().push(layer)

  let n0 = in_layer_counter_bb_new_node(layer, 0)
  let n1 = in_layer_counter_bb_new_node(layer, 1)
  let n2 = in_layer_counter_bb_new_node(layer, 2)
  let n3 = in_layer_counter_bb_new_node(layer, 3)

  let p0 = in_layer_counter_bb_new_port(
    n0,
    in_layer_counter_bb_port_side_east(),
    0,
  )
  let p1 = in_layer_counter_bb_new_port(
    n1,
    in_layer_counter_bb_port_side_east(),
    1,
  )
  let p2 = in_layer_counter_bb_new_port(
    n2,
    in_layer_counter_bb_port_side_east(),
    2,
  )
  let p3 = in_layer_counter_bb_new_port(
    n3,
    in_layer_counter_bb_port_side_east(),
    3,
  )

  in_layer_counter_bb_connect(p0, p2)
  in_layer_counter_bb_connect(p1, p3)

  let left_counter = new_crossings_counter(Array::make(4, 0))
  let right_counter = new_crossings_counter(Array::make(4, 0))
  let layer_nodes = [n0, n1, n2, n3]
  ignore(
    left_counter.init_port_positions_for_in_layer_crossings(
      layer_nodes,
      in_layer_counter_bb_port_side_west(),
    ),
  )
  ignore(
    right_counter.init_port_positions_for_in_layer_crossings(
      layer_nodes,
      in_layer_counter_bb_port_side_east(),
    ),
  )

  let before = right_counter.count_in_layer_crossings_between_nodes_in_both_orders(
    n0,
    n1,
    in_layer_counter_bb_port_side_east(),
  )
  assert_eq(in_layer_counter_bb_pair_value(before.get_first()), 1)
  assert_eq(in_layer_counter_bb_pair_value(before.get_second()), 0)

  left_counter.switch_nodes(n0, n1, in_layer_counter_bb_port_side_west())
  right_counter.switch_nodes(n0, n1, in_layer_counter_bb_port_side_east())

  let after = right_counter.count_in_layer_crossings_between_nodes_in_both_orders(
    n1,
    n0,
    in_layer_counter_bb_port_side_east(),
  )
  assert_eq(in_layer_counter_bb_pair_value(after.get_first()), 0)
  assert_eq(in_layer_counter_bb_pair_value(after.get_second()), 1)
}
