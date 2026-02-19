///|
fn between_layer_bb_port_side_west() -> @core.PortSide {
  @core.port_side_values()[4]
}

///|
fn between_layer_bb_port_side_east() -> @core.PortSide {
  @core.port_side_values()[2]
}

///|
fn between_layer_bb_new_node(layer : Layer) -> LNode {
  let node = new_l_node()
  node.set_layer(Some(layer))
  node
}

///|
fn between_layer_bb_add_port(node : LNode, side : @core.PortSide) -> LPort {
  let port = new_l_port()
  port.set_side(side)
  port.set_node(Some(node))
  port
}

///|
fn between_layer_bb_connect_to_target_port(
  source : LNode,
  target_port : LPort,
) -> LPort {
  let source_port = between_layer_bb_add_port(
    source,
    between_layer_bb_port_side_east(),
  )
  let edge = new_l_edge()
  edge.set_source(Some(source_port))
  edge.set_target(Some(target_port))
  source_port
}

///|
fn between_layer_bb_current_order(graph : LGraph) -> Array[Array[LNode]] {
  let order = []
  for layer in graph.get_layers() {
    order.push(layer.get_nodes())
  }
  order
}

///|
fn between_layer_bb_assert_crossings(
  counter : BetweenLayerEdgeTwoNodeCrossingsCounter,
  upper_node : LNode,
  lower_node : LNode,
  both_upper_lower : Int,
  both_lower_upper : Int,
  west_upper_lower : Int,
  west_lower_upper : Int,
  east_upper_lower : Int,
  east_lower_upper : Int,
) -> Unit raise {
  counter.count_both_side_crossings(upper_node, lower_node)
  assert_eq(counter.get_upper_lower_crossings(), both_upper_lower)
  assert_eq(counter.get_lower_upper_crossings(), both_lower_upper)

  counter.count_western_edge_crossings(upper_node, lower_node)
  assert_eq(counter.get_upper_lower_crossings(), west_upper_lower)
  assert_eq(counter.get_lower_upper_crossings(), west_lower_upper)

  counter.count_eastern_edge_crossings(upper_node, lower_node)
  assert_eq(counter.get_upper_lower_crossings(), east_upper_lower)
  assert_eq(counter.get_lower_upper_crossings(), east_lower_upper)
}

///|
fn between_layer_bb_assert_graph_crossings(
  graph : LGraph,
  free_layer_index : Int,
  upper_node_index : Int,
  lower_node_index : Int,
  both_upper_lower : Int,
  both_lower_upper : Int,
  west_upper_lower : Int,
  west_lower_upper : Int,
  east_upper_lower : Int,
  east_lower_upper : Int,
) -> Unit raise {
  let order = between_layer_bb_current_order(graph)
  let counter = new_between_layer_edge_two_node_crossings_counter(
    order, free_layer_index,
  )
  let layer_nodes = graph.get_layers()[free_layer_index].get_nodes()
  let upper_node = layer_nodes[upper_node_index]
  let lower_node = layer_nodes[lower_node_index]
  between_layer_bb_assert_crossings(
    counter, upper_node, lower_node, both_upper_lower, both_lower_upper, west_upper_lower,
    west_lower_upper, east_upper_lower, east_lower_upper,
  )
}

///|
test "BetweenLayerEdgeTwoNodeCrossingsCounter returns zero for disconnected nodes" {
  let graph = new_l_graph()
  let layer = new_layer(graph)
  graph.get_layers().push(layer)

  let upper = between_layer_bb_new_node(layer)
  let lower = between_layer_bb_new_node(layer)
  let order = [[upper, lower]]
  let counter = new_between_layer_edge_two_node_crossings_counter(order, 0)

  counter.count_both_side_crossings(upper, lower)
  assert_eq(counter.get_upper_lower_crossings(), 0)
  assert_eq(counter.get_lower_upper_crossings(), 0)

  counter.count_eastern_edge_crossings(upper, lower)
  assert_eq(counter.get_upper_lower_crossings(), 0)
  assert_eq(counter.get_lower_upper_crossings(), 0)

  counter.count_western_edge_crossings(upper, lower)
  assert_eq(counter.get_upper_lower_crossings(), 0)
  assert_eq(counter.get_lower_upper_crossings(), 0)
}

///|
test "BetweenLayerEdgeTwoNodeCrossingsCounter counts simple west-side crossing" {
  let graph = new_l_graph()
  let left_layer = new_layer(graph)
  let right_layer = new_layer(graph)
  graph.get_layers().push(left_layer)
  graph.get_layers().push(right_layer)

  let left_top = between_layer_bb_new_node(left_layer)
  let left_bottom = between_layer_bb_new_node(left_layer)
  let right_top = between_layer_bb_new_node(right_layer)
  let right_bottom = between_layer_bb_new_node(right_layer)

  let right_top_port = between_layer_bb_add_port(
    right_top,
    between_layer_bb_port_side_west(),
  )
  let right_bottom_port = between_layer_bb_add_port(
    right_bottom,
    between_layer_bb_port_side_west(),
  )

  ignore(between_layer_bb_connect_to_target_port(left_top, right_bottom_port))
  ignore(between_layer_bb_connect_to_target_port(left_bottom, right_top_port))

  let order = [[left_top, left_bottom], [right_top, right_bottom]]
  let counter = new_between_layer_edge_two_node_crossings_counter(order, 1)

  counter.count_western_edge_crossings(right_top, right_bottom)
  assert_eq(counter.get_upper_lower_crossings(), 1)
  assert_eq(counter.get_lower_upper_crossings(), 0)

  counter.count_both_side_crossings(right_top, right_bottom)
  assert_eq(counter.get_upper_lower_crossings(), 1)
  assert_eq(counter.get_lower_upper_crossings(), 0)
}

///|
test "BetweenLayerEdgeTwoNodeCrossingsCounter keeps shared target port crossing-free" {
  let graph = new_l_graph()
  let left_layer = new_layer(graph)
  let right_layer = new_layer(graph)
  graph.get_layers().push(left_layer)
  graph.get_layers().push(right_layer)

  let left_top = between_layer_bb_new_node(left_layer)
  let left_bottom = between_layer_bb_new_node(left_layer)
  let right = between_layer_bb_new_node(right_layer)
  let right_port = between_layer_bb_add_port(
    right,
    between_layer_bb_port_side_west(),
  )

  ignore(between_layer_bb_connect_to_target_port(left_top, right_port))
  ignore(between_layer_bb_connect_to_target_port(left_top, right_port))
  ignore(between_layer_bb_connect_to_target_port(left_bottom, right_port))

  let order = [[left_top, left_bottom], [right]]
  let counter = new_between_layer_edge_two_node_crossings_counter(order, 0)
  counter.count_eastern_edge_crossings(left_top, left_bottom)

  assert_eq(counter.get_upper_lower_crossings(), 0)
  assert_eq(counter.get_lower_upper_crossings(), 0)
}

///|
test "BetweenLayerEdgeTwoNodeCrossingsCounter one-node graph has zero crossings" {
  let creator = new_greedy_switch_test_graph_creator()
  let graph = creator.get_one_node_graph()
  between_layer_bb_assert_graph_crossings(graph, 0, 0, 0, 0, 0, 0, 0, 0, 0)
}

///|
test "BetweenLayerEdgeTwoNodeCrossingsCounter handles multiple edges between same nodes" {
  let creator = new_greedy_switch_test_graph_creator()
  let graph = creator.get_multiple_edges_between_same_nodes_graph()
  between_layer_bb_assert_graph_crossings(graph, 1, 0, 1, 4, 0, 4, 0, 0, 0)
}

///|
test "BetweenLayerEdgeTwoNodeCrossingsCounter handles cross with extra middle node" {
  let creator = new_greedy_switch_test_graph_creator()
  let graph = creator.get_cross_with_extra_edge_in_between_graph()
  between_layer_bb_assert_graph_crossings(graph, 1, 0, 2, 1, 0, 1, 0, 0, 0)
}

///|
test "BetweenLayerEdgeTwoNodeCrossingsCounter ignores in-layer edges" {
  let creator = new_greedy_switch_test_graph_creator()
  let graph = creator.get_in_layer_edges_graph()
  between_layer_bb_assert_graph_crossings(graph, 1, 0, 2, 0, 0, 0, 0, 0, 0)
}

///|
test "BetweenLayerEdgeTwoNodeCrossingsCounter ignores self loops" {
  let creator = new_greedy_switch_test_graph_creator()
  let graph = creator.get_cross_with_many_self_loops_graph()
  between_layer_bb_assert_graph_crossings(graph, 1, 0, 1, 1, 0, 1, 0, 0, 0)
}

///|
test "BetweenLayerEdgeTwoNodeCrossingsCounter handles complex three-layer graph" {
  let creator = new_greedy_switch_test_graph_creator()
  let graph = creator.get_more_complex_three_layer_graph()
  between_layer_bb_assert_graph_crossings(graph, 1, 0, 1, 3, 4, 1, 1, 2, 3)
}

///|
test "BetweenLayerEdgeTwoNodeCrossingsCounter respects fixed port order" {
  let creator = new_greedy_switch_test_graph_creator()
  let graph = creator.get_fixed_port_order_graph()
  between_layer_bb_assert_graph_crossings(graph, 1, 0, 1, 1, 0, 1, 0, 0, 0)
}

///|
test "BetweenLayerEdgeTwoNodeCrossingsCounter switch-three-times scenario counts crossings" {
  let creator = new_greedy_switch_test_graph_creator()
  let graph = creator.get_graph()
  let left_nodes = creator.add_nodes_to_layer(2, creator.make_layer(graph))
  let right_nodes = creator.add_nodes_to_layer(4, creator.make_layer(graph))
  let left_top_port = creator.add_port_on_side(
    left_nodes[0],
    between_layer_bb_port_side_east(),
  )
  let left_lower_port = creator.add_port_on_side(
    left_nodes[1],
    between_layer_bb_port_side_east(),
  )
  let right_top_port = creator.add_port_on_side(
    right_nodes[0],
    between_layer_bb_port_side_west(),
  )

  creator.add_edge_between_ports(left_lower_port, right_top_port)
  creator.east_west_edge_from_to_port_node(left_lower_port, right_nodes[2])

  creator.add_edge_between_ports(left_top_port, right_top_port)
  creator.east_west_edge_from_to_port_node(left_top_port, right_nodes[1])
  creator.east_west_edge_from_to_port_node(left_top_port, right_nodes[3])

  creator.set_up_ids()
  between_layer_bb_assert_graph_crossings(graph, 0, 0, 1, 3, 2, 0, 0, 3, 2)
}

///|
test "BetweenLayerEdgeTwoNodeCrossingsCounter counts into-same-port scenario" {
  let creator = new_greedy_switch_test_graph_creator()
  let graph = creator.two_edges_into_same_port()
  between_layer_bb_assert_graph_crossings(graph, 1, 0, 1, 2, 0, 2, 0, 0, 0)
}

///|
test "BetweenLayerEdgeTwoNodeCrossingsCounter into-same-port can create crossings after switch" {
  let creator = new_greedy_switch_test_graph_creator()
  let graph = creator.get_graph()
  let left_layer = creator.make_layer(graph)
  let right_layer = creator.make_layer(graph)

  let top_left = creator.add_node_to_layer(left_layer)
  let bottom_left = creator.add_node_to_layer(left_layer)
  let top_right = creator.add_node_to_layer(right_layer)
  let bottom_right = creator.add_node_to_layer(right_layer)

  let top_right_port = creator.add_port_on_side(
    top_right,
    between_layer_bb_port_side_west(),
  )
  let bottom_left_port = creator.add_port_on_side(
    bottom_left,
    between_layer_bb_port_side_east(),
  )
  creator.add_edge_between_ports(bottom_left_port, top_right_port)

  let top_left_port = creator.add_port_on_side(
    top_left,
    between_layer_bb_port_side_east(),
  )
  creator.add_edge_between_ports(top_left_port, top_right_port)
  creator.east_west_edge_from_to_nodes(bottom_left, bottom_right)

  creator.set_up_ids()
  between_layer_bb_assert_graph_crossings(graph, 0, 0, 1, 0, 1, 0, 0, 0, 1)
}

///|
test "BetweenLayerEdgeTwoNodeCrossingsCounter into-same-port can resolve crossings after switch" {
  let creator = new_greedy_switch_test_graph_creator()
  let graph = creator.get_graph()
  let left_layer = creator.make_layer(graph)
  let right_layer = creator.make_layer(graph)

  let top_left = creator.add_node_to_layer(left_layer)
  let bottom_left = creator.add_node_to_layer(left_layer)
  let top_right = creator.add_node_to_layer(right_layer)
  let bottom_right = creator.add_node_to_layer(right_layer)

  let top_left_port = creator.add_port_on_side(
    top_left,
    between_layer_bb_port_side_east(),
  )
  let bottom_left_port = creator.add_port_on_side(
    bottom_left,
    between_layer_bb_port_side_east(),
  )
  let bottom_right_port = creator.add_port_on_side(
    bottom_right,
    between_layer_bb_port_side_west(),
  )

  creator.add_edge_between_ports(top_left_port, bottom_right_port)
  creator.add_edge_between_ports(bottom_left_port, bottom_right_port)
  creator.east_west_edge_from_to_nodes(bottom_left, top_right)

  creator.set_up_ids()
  between_layer_bb_assert_graph_crossings(graph, 0, 0, 1, 1, 0, 0, 0, 1, 0)
}

///|
test "BetweenLayerEdgeTwoNodeCrossingsCounter into-same-port from east with fixed order" {
  let creator = new_greedy_switch_test_graph_creator()
  let graph = creator.get_graph()
  let left_layer = creator.make_layer(graph)
  let right_layer = creator.make_layer(graph)

  let top_left = creator.add_node_to_layer(left_layer)
  let bottom_left = creator.add_node_to_layer(left_layer)
  let top_right = creator.add_node_to_layer(right_layer)
  let bottom_right = creator.add_node_to_layer(right_layer)

  creator.set_fixed_order_constraint(bottom_left)
  creator.set_fixed_order_constraint(top_right)

  let top_left_port = creator.add_port_on_side(
    top_left,
    between_layer_bb_port_side_east(),
  )
  let bottom_left_port = creator.add_port_on_side(
    bottom_left,
    between_layer_bb_port_side_east(),
  )
  let top_right_port = creator.add_port_on_side(
    top_right,
    between_layer_bb_port_side_west(),
  )
  let bottom_right_port = creator.add_port_on_side(
    bottom_right,
    between_layer_bb_port_side_west(),
  )

  creator.add_edge_between_ports(bottom_left_port, bottom_right_port)
  creator.add_edge_between_ports(bottom_left_port, top_right_port)
  creator.add_edge_between_ports(top_left_port, top_right_port)

  creator.set_up_ids()
  between_layer_bb_assert_graph_crossings(graph, 0, 0, 1, 0, 1, 0, 0, 0, 1)
}

///|
test "BetweenLayerEdgeTwoNodeCrossingsCounter multiple edges into same port stay crossing-free" {
  let creator = new_greedy_switch_test_graph_creator()
  let graph = creator.get_graph()
  let left_layer = creator.make_layer(graph)
  let right_layer = creator.make_layer(graph)

  let top_left = creator.add_node_to_layer(left_layer)
  let bottom_left = creator.add_node_to_layer(left_layer)
  let bottom_right = creator.add_node_to_layer(right_layer)
  let bottom_right_port = creator.add_port_on_side(
    bottom_right,
    between_layer_bb_port_side_west(),
  )

  creator.east_west_edge_from_to_node_port(top_left, bottom_right_port)
  creator.east_west_edge_from_to_node_port(top_left, bottom_right_port)
  creator.east_west_edge_from_to_node_port(bottom_left, bottom_right_port)

  creator.set_up_ids()
  between_layer_bb_assert_graph_crossings(graph, 0, 0, 1, 0, 0, 0, 0, 0, 0)
}
