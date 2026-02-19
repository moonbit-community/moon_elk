///|
fn all_crossings_test_new_node(layer : Layer, id : Int) -> LNode {
  let node = new_l_node()
  node.set_layer(Some(layer))
  node.set_id(id)
  node
}

///|
fn all_crossings_test_new_port(node : LNode, id : Int) -> LPort {
  let port = new_l_port()
  port.set_id(id)
  port.set_node(Some(node))
  port
}

///|
fn all_crossings_test_connect(source : LPort, target : LPort) -> LEdge {
  let edge = new_l_edge()
  edge.set_source(Some(source))
  edge.set_target(Some(target))
  edge
}

///|
test "AllCrossingsCounter counts one crossing" {
  let graph = new_l_graph()
  let left_layer = new_layer(graph)
  let right_layer = new_layer(graph)
  graph.get_layers().push(left_layer)
  graph.get_layers().push(right_layer)

  let top_left = all_crossings_test_new_node(left_layer, 0)
  let bottom_left = all_crossings_test_new_node(left_layer, 1)
  let top_right = all_crossings_test_new_node(right_layer, 0)
  let bottom_right = all_crossings_test_new_node(right_layer, 1)

  let top_left_port = all_crossings_test_new_port(top_left, 0)
  top_left_port.set_side(@core.PortSide::East)
  let bottom_left_port = all_crossings_test_new_port(bottom_left, 1)
  bottom_left_port.set_side(@core.PortSide::East)
  let top_right_port = all_crossings_test_new_port(top_right, 2)
  top_right_port.set_side(@core.PortSide::West)
  let bottom_right_port = all_crossings_test_new_port(bottom_right, 3)
  bottom_right_port.set_side(@core.PortSide::West)

  ignore(all_crossings_test_connect(top_left_port, bottom_right_port))
  ignore(all_crossings_test_connect(bottom_left_port, top_right_port))

  let order = [[top_left, bottom_left], [top_right, bottom_right]]
  let counter = new_all_crossings_counter(order)
  i_initializable_init([counter.as_initializable()], order)

  assert_eq(counter.count_all_crossings(order), 1)
}

///|
test "AllCrossingsCounter returns zero for empty graph" {
  let order : Array[Array[LNode]] = []
  let counter = new_all_crossings_counter(order)
  i_initializable_init([counter.as_initializable()], order)
  assert_eq(counter.count_all_crossings(order), 0)
}
