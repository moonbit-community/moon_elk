///|
fn ns_counter_test_new_node(
  layer : @runtime.Layer,
  id : Int,
  node_type : @runtime.NodeType,
) -> @runtime.LNode {
  let node = @runtime.new_l_node()
  node.set_layer(Some(layer))
  node.set_id(id)
  node.set_type(node_type)
  node
}

///|
fn ns_counter_test_new_port(node : @runtime.LNode, id : Int) -> @runtime.LPort {
  let port = @runtime.new_l_port()
  port.set_id(id)
  port.set_node(Some(node))
  port
}

///|
fn ns_counter_test_connect(
  source : @runtime.LPort,
  target : @runtime.LPort,
) -> @runtime.LEdge {
  let edge = @runtime.new_l_edge()
  edge.set_source(Some(source))
  edge.set_target(Some(target))
  edge
}

///|
test "North south crossing counter returns zero when no north south ports exist" {
  let graph = @runtime.new_l_graph()
  let layer = @runtime.new_layer(graph)
  graph.get_layers().push(layer)

  let n0 = ns_counter_test_new_node(layer, 0, Normal)
  let n1 = ns_counter_test_new_node(layer, 1, Normal)

  let p0 = ns_counter_test_new_port(n0, 0)
  p0.set_side(East)
  let p1 = ns_counter_test_new_port(n1, 1)
  p1.set_side(East)
  ignore(ns_counter_test_connect(p0, p1))

  let counter = new_crossings_counter(Array::make(2, 0))
  assert_eq(counter.count_north_south_port_crossings_in_layer([n0, n1]), 0)
}

///|
test "North south crossing counter handles one dummy edge without crossings" {
  let graph = @runtime.new_l_graph()
  let layer = @runtime.new_layer(graph)
  graph.get_layers().push(layer)

  let normal = ns_counter_test_new_node(layer, 0, Normal)
  let dummy = ns_counter_test_new_node(layer, 1, NorthSouthPort)

  let normal_north = ns_counter_test_new_port(normal, 0)
  normal_north.set_side(North)
  normal_north.set_property_l_node(
    @runtime.internal_properties_port_dummy,
    Some(dummy),
  )

  let dummy_west = ns_counter_test_new_port(dummy, 1)
  dummy_west.set_side(West)
  let dummy_east = ns_counter_test_new_port(dummy, 2)
  dummy_east.set_side(East)
  dummy_west.set_property_l_port(
    @runtime.internal_properties_origin_l_port,
    Some(normal_north),
  )

  ignore(ns_counter_test_connect(dummy_west, dummy_east))

  let counter = new_crossings_counter(Array::make(3, 0))
  assert_eq(
    counter.count_north_south_port_crossings_in_layer([normal, dummy]),
    0,
  )
}
