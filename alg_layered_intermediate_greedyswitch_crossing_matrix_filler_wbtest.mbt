///|
fn crossing_matrix_test_new_node(layer : Layer, id : Int) -> LNode {
  let node = new_l_node()
  node.set_layer(Some(layer))
  node.set_id(id)
  node
}

///|
fn crossing_matrix_test_new_port(
  node : LNode,
  side : PortSide,
  id : Int,
) -> LPort {
  let port = new_l_port()
  port.set_side(side)
  port.set_node(Some(node))
  port.set_id(id)
  port
}

///|
fn crossing_matrix_test_connect(source : LPort, target : LPort) -> Unit {
  let edge = new_l_edge()
  edge.set_source(Some(source))
  edge.set_target(Some(target))
}

///|
test "CrossingMatrixFiller one-sided west returns crossing entry" {
  let graph = new_l_graph()
  let left_layer = new_layer(graph)
  let right_layer = new_layer(graph)
  graph.get_layers().push(left_layer)
  graph.get_layers().push(right_layer)

  let left_upper = crossing_matrix_test_new_node(left_layer, 0)
  let left_lower = crossing_matrix_test_new_node(left_layer, 1)
  let right_upper = crossing_matrix_test_new_node(right_layer, 0)
  let right_lower = crossing_matrix_test_new_node(right_layer, 1)

  let left_upper_port = crossing_matrix_test_new_port(
    left_upper,
    PortSide::East,
    0,
  )
  let left_lower_port = crossing_matrix_test_new_port(
    left_lower,
    PortSide::East,
    1,
  )
  let right_upper_port = crossing_matrix_test_new_port(
    right_upper,
    PortSide::West,
    2,
  )
  let right_lower_port = crossing_matrix_test_new_port(
    right_lower,
    PortSide::West,
    3,
  )

  crossing_matrix_test_connect(left_upper_port, right_lower_port)
  crossing_matrix_test_connect(left_lower_port, right_upper_port)

  let node_order = [[left_upper, left_lower], [right_upper, right_lower]]
  let filler = new_crossing_matrix_filler(
    GreedySwitchType::OneSided,
    node_order,
    1,
    CrossingCountSide::West,
  )

  assert_eq(filler.get_crossing_matrix_entry(right_upper, right_lower), 1)
  assert_eq(filler.get_crossing_matrix_entry(right_lower, right_upper), 0)
}

///|
test "CrossingMatrixFiller two-sided writes symmetric entries" {
  let graph = new_l_graph()
  let left_layer = new_layer(graph)
  let right_layer = new_layer(graph)
  graph.get_layers().push(left_layer)
  graph.get_layers().push(right_layer)

  let left_upper = crossing_matrix_test_new_node(left_layer, 0)
  let left_lower = crossing_matrix_test_new_node(left_layer, 1)
  let right_upper = crossing_matrix_test_new_node(right_layer, 0)
  let right_lower = crossing_matrix_test_new_node(right_layer, 1)

  let left_upper_port = crossing_matrix_test_new_port(
    left_upper,
    PortSide::East,
    0,
  )
  let left_lower_port = crossing_matrix_test_new_port(
    left_lower,
    PortSide::East,
    1,
  )
  let right_upper_port = crossing_matrix_test_new_port(
    right_upper,
    PortSide::West,
    2,
  )
  let right_lower_port = crossing_matrix_test_new_port(
    right_lower,
    PortSide::West,
    3,
  )

  crossing_matrix_test_connect(left_upper_port, right_lower_port)
  crossing_matrix_test_connect(left_lower_port, right_upper_port)

  let node_order = [[left_upper, left_lower], [right_upper, right_lower]]
  let filler = new_crossing_matrix_filler(
    GreedySwitchType::TwoSided,
    node_order,
    1,
    CrossingCountSide::West,
  )

  assert_eq(filler.get_crossing_matrix_entry(right_upper, right_lower), 1)
  assert_eq(filler.get_crossing_matrix_entry(right_lower, right_upper), 0)
}
