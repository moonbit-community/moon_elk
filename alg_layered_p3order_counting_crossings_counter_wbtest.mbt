///|
fn crossings_test_new_node(layer : Layer, id : Int) -> LNode {
  let node = new_l_node()
  node.set_layer(Some(layer))
  node.set_id(id)
  node
}

///|
fn crossings_test_new_port(node : LNode, id : Int) -> LPort {
  let port = new_l_port()
  port.set_id(id)
  port.set_node(Some(node))
  port
}

///|
fn crossings_test_connect(source : LPort, target : LPort) -> LEdge {
  let edge = new_l_edge()
  edge.set_source(Some(source))
  edge.set_target(Some(target))
  edge
}

///|
test "CrossingsCounter counts one crossing between two layers" {
  let graph = new_l_graph()
  let left_layer = new_layer(graph)
  let right_layer = new_layer(graph)
  graph.get_layers().push(left_layer)
  graph.get_layers().push(right_layer)

  let top_left = crossings_test_new_node(left_layer, 0)
  let bottom_left = crossings_test_new_node(left_layer, 1)
  let top_right = crossings_test_new_node(right_layer, 0)
  let bottom_right = crossings_test_new_node(right_layer, 1)

  let top_left_port = crossings_test_new_port(top_left, 0)
  top_left_port.set_side(PortSide::East)
  let bottom_left_port = crossings_test_new_port(bottom_left, 1)
  bottom_left_port.set_side(PortSide::East)
  let top_right_port = crossings_test_new_port(top_right, 2)
  top_right_port.set_side(PortSide::West)
  let bottom_right_port = crossings_test_new_port(bottom_right, 3)
  bottom_right_port.set_side(PortSide::West)

  ignore(crossings_test_connect(top_left_port, bottom_right_port))
  ignore(crossings_test_connect(bottom_left_port, top_right_port))

  let counter = new_crossings_counter(Array::make(4, 0))
  let crossings = counter.count_crossings_between_layers(
    [top_left, bottom_left],
    [top_right, bottom_right],
  )

  assert_eq(crossings, 1)
}

///|
test "CrossingsCounter counts in-layer crossings on one side" {
  let graph = new_l_graph()
  let layer = new_layer(graph)
  graph.get_layers().push(layer)

  let n0 = crossings_test_new_node(layer, 0)
  let n1 = crossings_test_new_node(layer, 1)
  let n2 = crossings_test_new_node(layer, 2)
  let n3 = crossings_test_new_node(layer, 3)

  let p0 = crossings_test_new_port(n0, 0)
  p0.set_side(PortSide::East)
  let p1 = crossings_test_new_port(n1, 1)
  p1.set_side(PortSide::East)
  let p2 = crossings_test_new_port(n2, 2)
  p2.set_side(PortSide::East)
  let p3 = crossings_test_new_port(n3, 3)
  p3.set_side(PortSide::East)

  ignore(crossings_test_connect(p0, p2))
  ignore(crossings_test_connect(p1, p3))

  let counter = new_crossings_counter(Array::make(4, 0))
  let crossings = counter.count_in_layer_crossings_on_side(
    [n0, n1, n2, n3],
    PortSide::East,
  )

  assert_eq(crossings, 1)
}
