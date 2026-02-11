///|
fn greedy_port_test_new_node(layer : Layer) -> LNode {
  let node = new_l_node()
  node.set_layer(Some(layer))
  node
}

///|
fn greedy_port_test_add_port(node : LNode, side : PortSide) -> LPort {
  let port = new_l_port()
  port.set_side(side)
  port.set_node(Some(node))
  port
}

///|
fn greedy_port_test_connect_to_target_port(
  source : LNode,
  target_port : LPort,
) -> LPort {
  let source_port = greedy_port_test_add_port(source, PortSide::East)
  let edge = new_l_edge()
  edge.set_source(Some(source_port))
  edge.set_target(Some(target_port))
  source_port
}

///|
fn greedy_port_test_assign_port_ids(node_order : Array[Array[LNode]]) -> Unit {
  let mut id = 0
  for layer in node_order {
    for node in layer {
      for port in node.get_ports() {
        port.set_id(id)
        id = id + 1
      }
    }
  }
}

///|
fn greedy_port_test_build_simple_crossing() -> (
  Array[Array[LNode]],
  LNode,
  LPort,
  LPort,
) {
  let graph = new_l_graph()
  let left_layer = new_layer(graph)
  let right_layer = new_layer(graph)
  graph.get_layers().push(left_layer)
  graph.get_layers().push(right_layer)

  let left = greedy_port_test_new_node(left_layer)
  let right_top = greedy_port_test_new_node(right_layer)
  let right_bottom = greedy_port_test_new_node(right_layer)

  let left_top_port = greedy_port_test_add_port(left, PortSide::East)
  let left_bottom_port = greedy_port_test_add_port(left, PortSide::East)
  let right_top_port = greedy_port_test_add_port(right_top, PortSide::West)
  let right_bottom_port = greedy_port_test_add_port(
    right_bottom,
    PortSide::West,
  )

  let edge_top = new_l_edge()
  edge_top.set_source(Some(left_top_port))
  edge_top.set_target(Some(right_bottom_port))

  let edge_bottom = new_l_edge()
  edge_bottom.set_source(Some(left_bottom_port))
  edge_bottom.set_target(Some(right_top_port))

  let node_order = [[left], [right_top, right_bottom]]
  greedy_port_test_assign_port_ids(node_order)
  (node_order, left, left_top_port, left_bottom_port)
}

///|
test "GreedyPortDistributor swaps west ports when switching reduces crossings" {
  let (node_order, left, left_top_port, left_bottom_port) = greedy_port_test_build_simple_crossing()
  let distributor = new_greedy_port_distributor()
  i_initializable_init([distributor.as_initializable()], node_order)

  let improved = distributor.distribute_ports_while_sweeping(
    node_order, 0, false,
  )

  assert_true(improved)
  assert_eq(left.get_ports()[0].get_handle(), left_bottom_port.get_handle())
  assert_eq(left.get_ports()[1].get_handle(), left_top_port.get_handle())
}

///|
test "GreedyPortDistributor keeps fixed-order west ports unchanged" {
  let (node_order, left, left_top_port, left_bottom_port) = greedy_port_test_build_simple_crossing()
  left.set_property_string(port_constraints, "FIXED_ORDER")
  let distributor = new_greedy_port_distributor()
  i_initializable_init([distributor.as_initializable()], node_order)

  let improved = distributor.distribute_ports_while_sweeping(
    node_order, 0, false,
  )

  assert_false(improved)
  assert_eq(left.get_ports()[0].get_handle(), left_top_port.get_handle())
  assert_eq(left.get_ports()[1].get_handle(), left_bottom_port.get_handle())
}
