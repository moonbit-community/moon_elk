///|
fn port_distributor_test_new_node(layer : Layer) -> LNode {
  let node = new_l_node()
  node.set_layer(Some(layer))
  node
}

///|
fn port_distributor_test_connect(
  source : LNode,
  target : LNode,
) -> (LPort, LPort) {
  let source_port = new_l_port()
  source_port.set_side(@core.PortSide::East)
  source_port.set_node(Some(source))

  let target_port = new_l_port()
  target_port.set_side(@core.PortSide::West)
  target_port.set_node(Some(target))

  let edge = new_l_edge()
  edge.set_source(Some(source_port))
  edge.set_target(Some(target_port))
  (source_port, target_port)
}

///|
fn port_distributor_test_two_layer_crossing_graph() -> (
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

  let left_top = port_distributor_test_new_node(left_layer)
  let left_bottom = port_distributor_test_new_node(left_layer)
  let right = port_distributor_test_new_node(right_layer)

  let (_, right_top_port) = port_distributor_test_connect(left_top, right)
  let (_, right_bottom_port) = port_distributor_test_connect(left_bottom, right)

  ([[left_top, left_bottom], [right]], right, right_top_port, right_bottom_port)
}

///|
test "AbstractBarycenterPortDistributor reorders western ports to remove simple cross" {
  let (node_order, right, right_top_port, right_bottom_port) = port_distributor_test_two_layer_crossing_graph()
  let distributor = new_layer_total_port_distributor(node_order.length())
  i_initializable_init([distributor.as_initializable()], node_order)

  ignore(distributor.distribute_ports_while_sweeping(node_order, 1, true))

  assert_eq(right.get_ports()[0].get_handle(), right_bottom_port.get_handle())
  assert_eq(right.get_ports()[1].get_handle(), right_top_port.get_handle())
}

///|
test "AbstractBarycenterPortDistributor keeps fixed-order ports untouched" {
  let (node_order, right, right_top_port, right_bottom_port) = port_distributor_test_two_layer_crossing_graph()
  right.set_property_string(@core.port_constraints, "FIXED_ORDER")
  let distributor = new_layer_total_port_distributor(node_order.length())
  i_initializable_init([distributor.as_initializable()], node_order)

  ignore(distributor.distribute_ports_while_sweeping(node_order, 1, true))

  assert_eq(right.get_ports()[0].get_handle(), right_top_port.get_handle())
  assert_eq(right.get_ports()[1].get_handle(), right_bottom_port.get_handle())
}

///|
test "LayerTotalPortDistributor assigns consecutive output ranks" {
  let graph = new_l_graph()
  let left_layer = new_layer(graph)
  let right_layer = new_layer(graph)
  graph.get_layers().push(left_layer)
  graph.get_layers().push(right_layer)

  let source = port_distributor_test_new_node(left_layer)
  let target_a = port_distributor_test_new_node(right_layer)
  let target_b = port_distributor_test_new_node(right_layer)

  let (source_port_a, _) = port_distributor_test_connect(source, target_a)
  let (source_port_b, _) = port_distributor_test_connect(source, target_b)

  let node_order = [[source], [target_a, target_b]]
  let distributor = new_layer_total_port_distributor(node_order.length())
  i_initializable_init([distributor.as_initializable()], node_order)
  distributor.calculate_port_ranks(node_order[0], PortType::Output)

  let ranks = distributor.get_port_ranks()
  assert_eq(ranks[source_port_a.get_id()], 1.0)
  assert_eq(ranks[source_port_b.get_id()], 2.0)
}

///|
test "NodeRelativePortDistributor normalizes output ranks inside one node band" {
  let graph = new_l_graph()
  let left_layer = new_layer(graph)
  let right_layer = new_layer(graph)
  graph.get_layers().push(left_layer)
  graph.get_layers().push(right_layer)

  let source = port_distributor_test_new_node(left_layer)
  let target_a = port_distributor_test_new_node(right_layer)
  let target_b = port_distributor_test_new_node(right_layer)

  let (source_port_a, _) = port_distributor_test_connect(source, target_a)
  let (source_port_b, _) = port_distributor_test_connect(source, target_b)

  let node_order = [[source], [target_a, target_b]]
  let distributor = new_node_relative_port_distributor(node_order.length())
  i_initializable_init([distributor.as_initializable()], node_order)
  distributor.calculate_port_ranks(node_order[0], PortType::Output)

  let ranks = distributor.get_port_ranks()
  assert_true((ranks[source_port_a.get_id()] - 1.0 / 3.0).abs() < 0.000000001)
  assert_true((ranks[source_port_b.get_id()] - 2.0 / 3.0).abs() < 0.000000001)
}
