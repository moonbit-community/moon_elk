///|
fn in_layer_counter_bb_port_side_east() -> @core.PortSide {
  @core.port_side_values()[2]
}

///|
fn in_layer_counter_bb_port_side_west() -> @core.PortSide {
  @core.port_side_values()[4]
}

///|
fn in_layer_counter_bb_pair_value(value : Int?) -> Int {
  match value {
    Some(v) => v
    None => 0
  }
}

///|
fn in_layer_counter_bb_port_count(current_order : Array[Array[LNode]]) -> Int {
  let mut count = 0
  for layer in current_order {
    for node in layer {
      count = count + node.get_ports().length()
    }
  }
  count
}

///|
fn in_layer_counter_bb_graph_order(graph : LGraph) -> Array[Array[LNode]] {
  let order = []
  for layer in graph.get_layers() {
    order.push(layer.get_nodes())
  }
  order
}

///|
fn in_layer_counter_bb_init_counters(
  graph : LGraph,
  layer_index : Int,
) -> (CrossingsCounter, CrossingsCounter, Array[LNode]) {
  let current_order = in_layer_counter_bb_graph_order(graph)
  let node_order = current_order[layer_index]
  for i in 0..<node_order.length() {
    node_order[i].set_id(i)
  }

  let left_counter = new_crossings_counter(
    Array::make(in_layer_counter_bb_port_count(current_order), 0),
  )
  let right_counter = new_crossings_counter(
    Array::make(in_layer_counter_bb_port_count(current_order), 0),
  )

  ignore(
    left_counter.init_port_positions_for_in_layer_crossings(
      node_order,
      in_layer_counter_bb_port_side_west(),
    ),
  )
  ignore(
    right_counter.init_port_positions_for_in_layer_crossings(
      node_order,
      in_layer_counter_bb_port_side_east(),
    ),
  )

  (left_counter, right_counter, node_order)
}

///|
fn in_layer_counter_bb_count_crossings(
  left_counter : CrossingsCounter,
  right_counter : CrossingsCounter,
  node_order : Array[LNode],
  upper_node_index : Int,
  lower_node_index : Int,
) -> (Int, Int) {
  let left_crossings = left_counter.count_in_layer_crossings_between_nodes_in_both_orders(
    node_order[upper_node_index],
    node_order[lower_node_index],
    in_layer_counter_bb_port_side_west(),
  )
  let right_crossings = right_counter.count_in_layer_crossings_between_nodes_in_both_orders(
    node_order[upper_node_index],
    node_order[lower_node_index],
    in_layer_counter_bb_port_side_east(),
  )

  (
    in_layer_counter_bb_pair_value(left_crossings.get_first()) +
    in_layer_counter_bb_pair_value(right_crossings.get_first()),
    in_layer_counter_bb_pair_value(left_crossings.get_second()) +
    in_layer_counter_bb_pair_value(right_crossings.get_second()),
  )
}

///|
fn in_layer_counter_bb_switch_order_and_notify_counter(
  left_counter : CrossingsCounter,
  right_counter : CrossingsCounter,
  node_order : Array[LNode],
  index_one : Int,
  index_two : Int,
) -> Unit {
  left_counter.switch_nodes(
    node_order[index_one],
    node_order[index_two],
    in_layer_counter_bb_port_side_west(),
  )
  right_counter.switch_nodes(
    node_order[index_one],
    node_order[index_two],
    in_layer_counter_bb_port_side_east(),
  )
  let one = node_order[index_one]
  node_order[index_one] = node_order[index_two]
  node_order[index_two] = one
}

///|
fn in_layer_counter_bb_assert_crossings(
  left_counter : CrossingsCounter,
  right_counter : CrossingsCounter,
  node_order : Array[LNode],
  upper_node_index : Int,
  lower_node_index : Int,
  expected_upper_lower : Int,
  expected_lower_upper : Int,
) -> Unit raise {
  let (upper_lower, lower_upper) = in_layer_counter_bb_count_crossings(
    left_counter, right_counter, node_order, upper_node_index, lower_node_index,
  )
  assert_eq(upper_lower, expected_upper_lower)
  assert_eq(lower_upper, expected_lower_upper)
}

///|
test "InLayerEdgeTwoNodeCrossingCounter ignores in-between-layer edges" {
  let creator = new_greedy_switch_test_graph_creator()
  let graph = creator.get_cross_formed_graph()

  let (left_counter, right_counter, node_order) = in_layer_counter_bb_init_counters(
    graph, 1,
  )
  in_layer_counter_bb_assert_crossings(
    left_counter, right_counter, node_order, 0, 1, 0, 0,
  )
}

///|
test "InLayerEdgeTwoNodeCrossingCounter counts normal-edge crossing with in-layer edge" {
  let creator = new_greedy_switch_test_graph_creator()
  let graph = creator.get_in_layer_edges_graph()

  let (left_counter, right_counter, node_order) = in_layer_counter_bb_init_counters(
    graph, 1,
  )
  in_layer_counter_bb_assert_crossings(
    left_counter, right_counter, node_order, 0, 1, 1, 0,
  )
}

///|
test "InLayerEdgeTwoNodeCrossingCounter crossing appears when switched" {
  let creator = new_greedy_switch_test_graph_creator()
  let graph = creator.get_in_layer_edges_graph_which_results_in_crossings_when_switched()

  let (left_counter, right_counter, node_order) = in_layer_counter_bb_init_counters(
    graph, 1,
  )
  in_layer_counter_bb_assert_crossings(
    left_counter, right_counter, node_order, 1, 2, 0, 1,
  )
}

///|
test "InLayerEdgeTwoNodeCrossingCounter handles in-layer edge on lower node" {
  let creator = new_greedy_switch_test_graph_creator()
  let graph = creator.get_in_layer_edges_graph()

  let (left_counter, right_counter, node_order) = in_layer_counter_bb_init_counters(
    graph, 1,
  )
  in_layer_counter_bb_assert_crossings(
    left_counter, right_counter, node_order, 0, 1, 1, 0,
  )
}

///|
test "InLayerEdgeTwoNodeCrossingCounter updates after node-order switch" {
  let creator = new_greedy_switch_test_graph_creator()
  let graph = creator.get_in_layer_edges_graph()

  let (left_counter, right_counter, node_order) = in_layer_counter_bb_init_counters(
    graph, 1,
  )
  in_layer_counter_bb_switch_order_and_notify_counter(
    left_counter, right_counter, node_order, 1, 2,
  )
  in_layer_counter_bb_assert_crossings(
    left_counter, right_counter, node_order, 0, 1, 0, 0,
  )
}

///|
test "InLayerEdgeTwoNodeCrossingCounter fixed-port-order crossing to between-layer edge" {
  let creator = new_greedy_switch_in_layer_edge_test_graph_creator()
  let graph = creator.get_in_layer_edges_graph_with_crossings_to_between_layer_edge_with_fixed_port_order()

  let (left_counter, right_counter, node_order) = in_layer_counter_bb_init_counters(
    graph, 1,
  )
  in_layer_counter_bb_assert_crossings(
    left_counter, right_counter, node_order, 0, 1, 1, 2,
  )

  in_layer_counter_bb_switch_order_and_notify_counter(
    left_counter, right_counter, node_order, 0, 1,
  )
  in_layer_counter_bb_assert_crossings(
    left_counter, right_counter, node_order, 0, 1, 2, 1,
  )
}

///|
test "InLayerEdgeTwoNodeCrossingCounter fixed-port-order and normal-edge crossings" {
  let creator = new_greedy_switch_in_layer_edge_test_graph_creator()
  let graph = creator.get_in_layer_edges_with_fixed_port_order_and_normal_edge_crossings()

  let (left_counter, right_counter, node_order) = in_layer_counter_bb_init_counters(
    graph, 1,
  )
  in_layer_counter_bb_assert_crossings(
    left_counter, right_counter, node_order, 0, 1, 2, 1,
  )

  in_layer_counter_bb_switch_order_and_notify_counter(
    left_counter, right_counter, node_order, 0, 1,
  )
  in_layer_counter_bb_assert_crossings(
    left_counter, right_counter, node_order, 0, 1, 1, 2,
  )
}

///|
test "InLayerEdgeTwoNodeCrossingCounter ignores self loops" {
  let creator = new_greedy_switch_test_graph_creator()
  let graph = creator.get_cross_with_many_self_loops_graph()

  let (left_counter, right_counter, node_order) = in_layer_counter_bb_init_counters(
    graph, 1,
  )
  in_layer_counter_bb_assert_crossings(
    left_counter, right_counter, node_order, 0, 1, 0, 0,
  )
}

///|
test "InLayerEdgeTwoNodeCrossingCounter counts crossings on both sides" {
  let creator = new_greedy_switch_in_layer_edge_test_graph_creator()
  let graph = creator.get_in_layer_crossings_on_both_sides()

  let (left_counter, right_counter, node_order) = in_layer_counter_bb_init_counters(
    graph, 1,
  )
  in_layer_counter_bb_assert_crossings(
    left_counter, right_counter, node_order, 0, 1, 2, 0,
  )
}

///|
test "InLayerEdgeTwoNodeCrossingCounter fixed-port-order in-layer no crossing" {
  let creator = new_greedy_switch_test_graph_creator()
  let graph = creator.get_fixed_port_order_in_layer_edges_dont_cross_each_other()

  let (left_counter, right_counter, node_order) = in_layer_counter_bb_init_counters(
    graph, 0,
  )
  in_layer_counter_bb_assert_crossings(
    left_counter, right_counter, node_order, 0, 1, 0, 0,
  )
}

///|
test "InLayerEdgeTwoNodeCrossingCounter fixed-port-order remaining crossings are not counted" {
  let creator = new_greedy_switch_test_graph_creator()
  let graph = creator.get_fixed_port_order_in_layer_edges_with_crossings()

  let (left_counter, right_counter, node_order) = in_layer_counter_bb_init_counters(
    graph, 0,
  )
  in_layer_counter_bb_assert_crossings(
    left_counter, right_counter, node_order, 0, 1, 1, 1,
  )
}

///|
test "InLayerEdgeTwoNodeCrossingCounter one-node graph has zero crossings" {
  let creator = new_greedy_switch_test_graph_creator()
  let graph = creator.get_one_node_graph()

  let (left_counter, right_counter, node_order) = in_layer_counter_bb_init_counters(
    graph, 0,
  )
  in_layer_counter_bb_assert_crossings(
    left_counter, right_counter, node_order, 0, 0, 0, 0,
  )
}

///|
test "InLayerEdgeTwoNodeCrossingCounter more-complex in-layer graph" {
  let creator = new_greedy_switch_test_graph_creator()
  let graph = creator.get_more_complex_in_layer_graph()

  let (left_counter, right_counter, node_order) = in_layer_counter_bb_init_counters(
    graph, 1,
  )
  in_layer_counter_bb_assert_crossings(
    left_counter, right_counter, node_order, 0, 1, 6, 6,
  )
}

///|
test "InLayerEdgeTwoNodeCrossingCounter downward in-layer edges on lower node" {
  let creator = new_greedy_switch_in_layer_edge_test_graph_creator()
  let graph = creator.get_in_layer_edges_fixed_port_order_in_layer_and_in_between_layer_crossing()

  let (left_counter, right_counter, node_order) = in_layer_counter_bb_init_counters(
    graph, 1,
  )
  in_layer_counter_bb_assert_crossings(
    left_counter, right_counter, node_order, 0, 1, 2, 2,
  )
}

///|
test "InLayerEdgeTwoNodeCrossingCounter one-layer crossing disappears after switches" {
  let creator = new_greedy_switch_in_layer_edge_test_graph_creator()
  let graph = creator.get_one_layer_with_in_layer_crossings()

  let (left_counter, right_counter, node_order) = in_layer_counter_bb_init_counters(
    graph, 0,
  )

  in_layer_counter_bb_assert_crossings(
    left_counter, right_counter, node_order, 0, 1, 1, 0,
  )
  in_layer_counter_bb_assert_crossings(
    left_counter, right_counter, node_order, 1, 2, 1, 0,
  )
  in_layer_counter_bb_assert_crossings(
    left_counter, right_counter, node_order, 2, 3, 1, 0,
  )

  in_layer_counter_bb_switch_order_and_notify_counter(
    left_counter, right_counter, node_order, 0, 1,
  )
  in_layer_counter_bb_assert_crossings(
    left_counter, right_counter, node_order, 0, 1, 0, 1,
  )

  in_layer_counter_bb_switch_order_and_notify_counter(
    left_counter, right_counter, node_order, 0, 1,
  )
  in_layer_counter_bb_switch_order_and_notify_counter(
    left_counter, right_counter, node_order, 1, 2,
  )
  in_layer_counter_bb_assert_crossings(
    left_counter, right_counter, node_order, 1, 2, 0, 1,
  )

  in_layer_counter_bb_switch_order_and_notify_counter(
    left_counter, right_counter, node_order, 1, 2,
  )
  in_layer_counter_bb_switch_order_and_notify_counter(
    left_counter, right_counter, node_order, 2, 3,
  )
  in_layer_counter_bb_assert_crossings(
    left_counter, right_counter, node_order, 2, 3, 0, 1,
  )
}

///|
test "InLayerEdgeTwoNodeCrossingCounter handles multiple edges into one port" {
  let creator = new_greedy_switch_in_layer_edge_test_graph_creator()
  let graph = creator.get_in_layer_edges_multiple_edges_into_single_port()

  let (left_counter, right_counter, node_order) = in_layer_counter_bb_init_counters(
    graph, 1,
  )
  in_layer_counter_bb_assert_crossings(
    left_counter, right_counter, node_order, 1, 2, 2, 0,
  )
}

///|
test "InLayerEdgeTwoNodeCrossingCounter between-layer edges into free-order node cause crossings" {
  let creator = new_greedy_switch_test_graph_creator()
  let graph = creator.multiple_in_between_layer_edges_into_node_with_no_fixed_port_order_cause_crossings()

  let (left_counter, right_counter, node_order) = in_layer_counter_bb_init_counters(
    graph, 1,
  )
  in_layer_counter_bb_assert_crossings(
    left_counter, right_counter, node_order, 0, 1, 2, 0,
  )
  in_layer_counter_bb_assert_crossings(
    left_counter, right_counter, node_order, 1, 2, 2, 0,
  )
}

///|
test "InLayerEdgeTwoNodeCrossingCounter one-layer in-layer edges pass each other" {
  let creator = new_greedy_switch_in_layer_edge_test_graph_creator()
  let graph = creator.get_in_layer_one_layer_no_crossings()

  let (left_counter, right_counter, node_order) = in_layer_counter_bb_init_counters(
    graph, 0,
  )
  in_layer_counter_bb_assert_crossings(
    left_counter, right_counter, node_order, 0, 1, 0, 1,
  )
  in_layer_counter_bb_assert_crossings(
    left_counter, right_counter, node_order, 1, 2, 0, 0,
  )
  in_layer_counter_bb_assert_crossings(
    left_counter, right_counter, node_order, 2, 3, 0, 1,
  )
}

///|
test "InLayerEdgeTwoNodeCrossingCounter fixed-port-order crossing to in-layer edge" {
  let creator = new_greedy_switch_in_layer_edge_test_graph_creator()
  let graph = creator.get_in_layer_edges_fixed_port_order_in_layer_crossing()

  let (left_counter, right_counter, node_order) = in_layer_counter_bb_init_counters(
    graph, 0,
  )
  in_layer_counter_bb_assert_crossings(
    left_counter, right_counter, node_order, 1, 2, 1, 0,
  )
}

///|
test "InLayerEdgeTwoNodeCrossingCounter fixed-port-order two in-layer edges cross" {
  let creator = new_greedy_switch_in_layer_edge_test_graph_creator()
  let graph = creator.get_fixed_port_order_two_in_layer_edges_cross_each_other()

  let (left_counter, right_counter, node_order) = in_layer_counter_bb_init_counters(
    graph, 0,
  )
  in_layer_counter_bb_assert_crossings(
    left_counter, right_counter, node_order, 0, 1, 1, 0,
  )
}

///|
test "InLayerEdgeTwoNodeCrossingCounter multiple edges into one port stays crossing-free" {
  let creator = new_greedy_switch_test_graph_creator()
  let graph = creator.get_graph()
  let nodes = creator.add_nodes_to_layer(3, creator.make_layer(graph))
  let port_one = creator.add_port_on_side(
    nodes[0],
    in_layer_counter_bb_port_side_east(),
  )
  let port_two = creator.add_port_on_side(
    nodes[1],
    in_layer_counter_bb_port_side_east(),
  )
  let port_three = creator.add_port_on_side(
    nodes[2],
    in_layer_counter_bb_port_side_east(),
  )
  creator.add_edge_between_ports(port_one, port_three)
  creator.add_edge_between_ports(port_two, port_three)
  creator.set_up_ids()

  let (left_counter, right_counter, node_order) = in_layer_counter_bb_init_counters(
    graph, 0,
  )
  in_layer_counter_bb_assert_crossings(
    left_counter, right_counter, node_order, 0, 1, 0, 0,
  )
}
