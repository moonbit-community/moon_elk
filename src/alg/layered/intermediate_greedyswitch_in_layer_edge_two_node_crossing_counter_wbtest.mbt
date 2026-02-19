///|
fn in_layer_counter_test_new_node(layer : Layer, id : Int) -> LNode {
  let node = new_l_node()
  node.set_layer(Some(layer))
  node.set_id(id)
  node
}

///|
fn in_layer_counter_test_new_port(
  node : LNode,
  side : @core.PortSide,
  id : Int,
) -> LPort {
  let port = new_l_port()
  port.set_node(Some(node))
  port.set_side(side)
  port.set_id(id)
  port
}

///|
fn in_layer_counter_test_connect(source : LPort, target : LPort) -> Unit {
  let edge = new_l_edge()
  edge.set_source(Some(source))
  edge.set_target(Some(target))
}

///|
fn in_layer_counter_test_pair_value(value : Int?) -> Int {
  match value {
    Some(v) => v
    None => 0
  }
}

///|
test "In-layer two-node crossing counter ignores between-layer edges" {
  let graph = new_l_graph()
  let left_layer = new_layer(graph)
  let right_layer = new_layer(graph)
  graph.get_layers().push(left_layer)
  graph.get_layers().push(right_layer)

  let left_upper = in_layer_counter_test_new_node(left_layer, 0)
  let left_lower = in_layer_counter_test_new_node(left_layer, 1)
  let right_upper = in_layer_counter_test_new_node(right_layer, 0)
  let right_lower = in_layer_counter_test_new_node(right_layer, 1)

  let left_upper_port = in_layer_counter_test_new_port(
    left_upper,
    @core.PortSide::East,
    0,
  )
  let left_lower_port = in_layer_counter_test_new_port(
    left_lower,
    @core.PortSide::East,
    1,
  )
  let right_upper_port = in_layer_counter_test_new_port(
    right_upper,
    @core.PortSide::West,
    2,
  )
  let right_lower_port = in_layer_counter_test_new_port(
    right_lower,
    @core.PortSide::West,
    3,
  )

  in_layer_counter_test_connect(left_upper_port, right_lower_port)
  in_layer_counter_test_connect(left_lower_port, right_upper_port)

  let left_counter = new_crossings_counter(Array::make(4, 0))
  let right_counter = new_crossings_counter(Array::make(4, 0))
  ignore(
    left_counter.init_port_positions_for_in_layer_crossings(
      [left_upper, left_lower],
      @core.PortSide::West,
    ),
  )
  ignore(
    right_counter.init_port_positions_for_in_layer_crossings(
      [left_upper, left_lower],
      @core.PortSide::East,
    ),
  )

  let left_crossings = left_counter.count_in_layer_crossings_between_nodes_in_both_orders(
    left_upper,
    left_lower,
    @core.PortSide::West,
  )
  let right_crossings = right_counter.count_in_layer_crossings_between_nodes_in_both_orders(
    left_upper,
    left_lower,
    @core.PortSide::East,
  )

  let upper_lower = in_layer_counter_test_pair_value(left_crossings.get_first()) +
    in_layer_counter_test_pair_value(right_crossings.get_first())
  let lower_upper = in_layer_counter_test_pair_value(
      left_crossings.get_second(),
    ) +
    in_layer_counter_test_pair_value(right_crossings.get_second())

  assert_eq(upper_lower, 0)
  assert_eq(lower_upper, 0)
}

///|
test "In-layer two-node crossing counter detects crossing and updates after switch" {
  let graph = new_l_graph()
  let layer = new_layer(graph)
  graph.get_layers().push(layer)

  let n0 = in_layer_counter_test_new_node(layer, 0)
  let n1 = in_layer_counter_test_new_node(layer, 1)
  let n2 = in_layer_counter_test_new_node(layer, 2)
  let n3 = in_layer_counter_test_new_node(layer, 3)

  let p0 = in_layer_counter_test_new_port(n0, @core.PortSide::East, 0)
  let p1 = in_layer_counter_test_new_port(n1, @core.PortSide::East, 1)
  let p2 = in_layer_counter_test_new_port(n2, @core.PortSide::East, 2)
  let p3 = in_layer_counter_test_new_port(n3, @core.PortSide::East, 3)

  in_layer_counter_test_connect(p0, p2)
  in_layer_counter_test_connect(p1, p3)

  let left_counter = new_crossings_counter(Array::make(4, 0))
  let right_counter = new_crossings_counter(Array::make(4, 0))
  let layer_nodes = [n0, n1, n2, n3]
  ignore(
    left_counter.init_port_positions_for_in_layer_crossings(
      layer_nodes,
      @core.PortSide::West,
    ),
  )
  ignore(
    right_counter.init_port_positions_for_in_layer_crossings(
      layer_nodes,
      @core.PortSide::East,
    ),
  )

  let before = right_counter.count_in_layer_crossings_between_nodes_in_both_orders(
    n0,
    n1,
    @core.PortSide::East,
  )
  assert_eq(in_layer_counter_test_pair_value(before.get_first()), 1)
  assert_eq(in_layer_counter_test_pair_value(before.get_second()), 0)

  left_counter.switch_nodes(n0, n1, @core.PortSide::West)
  right_counter.switch_nodes(n0, n1, @core.PortSide::East)

  let after = right_counter.count_in_layer_crossings_between_nodes_in_both_orders(
    n1,
    n0,
    @core.PortSide::East,
  )
  assert_eq(in_layer_counter_test_pair_value(after.get_first()), 0)
  assert_eq(in_layer_counter_test_pair_value(after.get_second()), 1)
}
