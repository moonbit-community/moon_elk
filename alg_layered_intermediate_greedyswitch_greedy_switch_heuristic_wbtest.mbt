///|
fn greedy_switch_heuristic_test_new_node(
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
fn greedy_switch_heuristic_test_new_port(
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
fn greedy_switch_heuristic_test_connect(source : LPort, target : LPort) -> Unit {
  let edge = new_l_edge()
  edge.set_source(Some(source))
  edge.set_target(Some(target))
}

///|
fn greedy_switch_heuristic_test_cross_graph() -> (
  Array[Array[LNode]],
  LNode,
  LNode,
) {
  let graph = new_l_graph()
  let left_layer = new_layer(graph)
  let right_layer = new_layer(graph)
  graph.get_layers().push(left_layer)
  graph.get_layers().push(right_layer)

  let left_upper = greedy_switch_heuristic_test_new_node(
    left_layer,
    0,
    NodeType::Normal,
  )
  let left_lower = greedy_switch_heuristic_test_new_node(
    left_layer,
    1,
    NodeType::Normal,
  )
  let right_upper = greedy_switch_heuristic_test_new_node(
    right_layer,
    0,
    NodeType::Normal,
  )
  let right_lower = greedy_switch_heuristic_test_new_node(
    right_layer,
    1,
    NodeType::Normal,
  )

  let left_upper_port = greedy_switch_heuristic_test_new_port(
    left_upper,
    PortSide::East,
    0,
  )
  let left_lower_port = greedy_switch_heuristic_test_new_port(
    left_lower,
    PortSide::East,
    1,
  )
  let right_upper_port = greedy_switch_heuristic_test_new_port(
    right_upper,
    PortSide::West,
    2,
  )
  let right_lower_port = greedy_switch_heuristic_test_new_port(
    right_lower,
    PortSide::West,
    3,
  )

  greedy_switch_heuristic_test_connect(left_upper_port, right_lower_port)
  greedy_switch_heuristic_test_connect(left_lower_port, right_upper_port)

  (
    [[left_upper, left_lower], [right_upper, right_lower]],
    right_upper,
    right_lower,
  )
}

///|
test "GreedySwitchHeuristic one-sided switches free layer to reduce crossings" {
  let (node_order, right_upper, right_lower) = greedy_switch_heuristic_test_cross_graph()
  let graph_data = new_graph_info_holder(node_order)
  let heuristic = new_greedy_switch_heuristic(
    GreedySwitchType::OneSided,
    graph_data,
  )
  i_initializable_init([heuristic.as_initializable()], node_order)

  let improved = heuristic.minimize_crossings(node_order, 1, true, false)

  assert_true(improved)
  assert_eq(node_order[1][0].get_handle(), right_lower.get_handle())
  assert_eq(node_order[1][1].get_handle(), right_upper.get_handle())
}

///|
test "GreedySwitchHeuristic always_improves matches greedy type" {
  let graph_data = new_graph_info_holder([])
  let one_sided = new_greedy_switch_heuristic(
    GreedySwitchType::OneSided,
    graph_data,
  )
  let two_sided = new_greedy_switch_heuristic(
    GreedySwitchType::TwoSided,
    graph_data,
  )

  assert_false(one_sided.always_improves())
  assert_true(two_sided.always_improves())
}
