///|
fn median_test_seeded_random() -> @random.Rand {
  let seed_buffer = @buffer.new()
  seed_buffer.write_int64_le(1)
  seed_buffer.write_int64_le(0)
  seed_buffer.write_int64_le(0)
  seed_buffer.write_int64_le(0)
  @random.Rand::chacha8(seed=seed_buffer.to_bytes())
}

///|
fn median_test_new_node(layer : Layer, id : Int) -> LNode {
  let node = new_l_node()
  node.set_layer(Some(layer))
  node.set_id(id)
  node
}

///|
fn median_test_connect(source : LNode, target : LNode) -> Unit {
  let source_port = new_l_port()
  source_port.set_node(Some(source))
  source_port.set_side(@core.PortSide::East)
  source_port.set_id(source.get_ports().length())

  let target_port = new_l_port()
  target_port.set_node(Some(target))
  target_port.set_side(@core.PortSide::West)
  target_port.set_id(target.get_ports().length())

  let edge = new_l_edge()
  edge.set_source(Some(source_port))
  edge.set_target(Some(target_port))
}

///|
fn median_test_node_ids(nodes : Array[LNode]) -> Array[Int] {
  let ids = []
  for node in nodes {
    ids.push(node.get_id())
  }
  ids
}

///|
fn median_test_weight_ranks(nodes : Array[LNode]) -> Array[Int] {
  let ranks = []
  for node in nodes {
    ranks.push(node.get_property_double(internal_properties_weight).to_int())
  }
  ranks
}

///|
test "MedianHeuristic assigns contiguous first-layer ranks" {
  let graph = new_l_graph()
  let layer = new_layer(graph)
  layer.set_id(0)
  graph.get_layers().push(layer)

  let n0 = median_test_new_node(layer, 0)
  let n1 = median_test_new_node(layer, 1)
  let n2 = median_test_new_node(layer, 2)

  let order = [[n0, n1, n2]]
  let heuristic = new_median_heuristic(median_test_seeded_random())

  assert_eq(heuristic.set_first_layer_order(order, true), false)

  for node in order[0] {
    assert_true(node.has_property_double(internal_properties_weight))
  }
  debug_inspect(median_test_weight_ranks(order[0]), content="[1, 2, 3]")
}

///|
test "MedianHeuristic orders layer by propagated medians" {
  let graph = new_l_graph()
  let left_layer = new_layer(graph)
  left_layer.set_id(0)
  let right_layer = new_layer(graph)
  right_layer.set_id(1)
  graph.get_layers().push(left_layer)
  graph.get_layers().push(right_layer)

  let a = median_test_new_node(left_layer, 0)
  let b = median_test_new_node(left_layer, 1)
  let c = median_test_new_node(left_layer, 2)
  a.set_property_double(internal_properties_weight, 1.0)
  b.set_property_double(internal_properties_weight, 2.0)
  c.set_property_double(internal_properties_weight, 3.0)

  let x = median_test_new_node(right_layer, 0)
  let y = median_test_new_node(right_layer, 1)

  median_test_connect(b, x)
  median_test_connect(c, x)
  median_test_connect(a, y)

  let order = [[a, b, c], [x, y]]
  let heuristic = new_median_heuristic(median_test_seeded_random())

  assert_eq(heuristic.minimize_crossings(order, 1, true, false), false)

  debug_inspect(median_test_node_ids(order[1]), content="[1, 0]")
  assert_eq(order[1][0].get_property_double(internal_properties_weight), 1.0)
  assert_eq(order[1][1].get_property_double(internal_properties_weight), 3.0)
}
