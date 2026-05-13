///|
fn greedy_switch_processor_test_is_one_sided(
  greedy_type : GreedySwitchType,
) -> Bool {
  match greedy_type {
    GreedySwitchType::OneSided => true
    _ => false
  }
}

///|
fn greedy_switch_processor_test_types() -> Array[GreedySwitchType] {
  [GreedySwitchType::OneSided, GreedySwitchType::TwoSided]
}

///|
fn greedy_switch_processor_test_node_handles(
  nodes : Array[LNode],
) -> Array[Int] {
  let handles = []
  for node in nodes {
    handles.push(node.get_handle())
  }
  handles
}

///|
fn greedy_switch_processor_test_handles_to_string(
  handles : Array[Int],
) -> String {
  let parts = []
  for handle in handles {
    parts.push(handle.to_string())
  }
  "[" + parts.join(", ") + "]"
}

///|
fn greedy_switch_processor_test_assert_layer_order(
  actual : Array[LNode],
  expected : Array[LNode],
) -> Unit {
  let actual_handles = greedy_switch_processor_test_node_handles(actual)
  let expected_handles = greedy_switch_processor_test_node_handles(expected)
  if actual_handles != expected_handles {
    abort(
      "unexpected layer order actual=" +
      greedy_switch_processor_test_handles_to_string(actual_handles) +
      " expected=" +
      greedy_switch_processor_test_handles_to_string(expected_handles),
    )
  }
}

///|
struct GreedySwitchProcessorSweepSnapshot {
  node_order : Array[Array[LNode]]
  port_orders : Array[Array[Array[LPort]]]
}

///|
fn greedy_switch_processor_test_take_snapshot(
  node_order : Array[Array[LNode]],
) -> GreedySwitchProcessorSweepSnapshot {
  let snapshot_node_order = []
  let snapshot_port_orders = []
  for layer in node_order {
    let snapshot_layer_nodes = []
    let snapshot_layer_ports = []
    for node in layer {
      snapshot_layer_nodes.push(node)
      snapshot_layer_ports.push(node.get_ports().copy())
    }
    snapshot_node_order.push(snapshot_layer_nodes)
    snapshot_port_orders.push(snapshot_layer_ports)
  }
  { node_order: snapshot_node_order, port_orders: snapshot_port_orders }
}

///|
fn greedy_switch_processor_test_restore_snapshot(
  node_order : Array[Array[LNode]],
  snapshot : GreedySwitchProcessorSweepSnapshot,
) -> Unit {
  for layer_index in 0..<node_order.length() {
    let live_layer = node_order[layer_index]
    let snapshot_layer = snapshot.node_order[layer_index]
    for node_index in 0..<live_layer.length() {
      live_layer[node_index] = snapshot_layer[node_index]
    }

    let snapshot_layer_ports = snapshot.port_orders[layer_index]
    for node_index in 0..<snapshot_layer.length() {
      let node = snapshot_layer[node_index]
      let ports = node.get_ports()
      ports.clear()
      for port in snapshot_layer_ports[node_index] {
        ports.push(port)
      }
    }
  }
}

///|
fn greedy_switch_processor_test_transfer_node_order_to_graph(
  graph : LGraph,
  node_order : Array[Array[LNode]],
) -> Unit {
  let layers = graph.get_layers()
  for layer_index in 0..<layers.length() {
    let layer_nodes = layers[layer_index].get_nodes()
    for node_index in 0..<layer_nodes.length() {
      layer_nodes[node_index] = node_order[layer_index][node_index]
    }
  }
}

///|
fn greedy_switch_processor_test_first_index(
  is_forward_sweep : Bool,
  length : Int,
) -> Int {
  if is_forward_sweep {
    0
  } else {
    length - 1
  }
}

///|
fn greedy_switch_processor_test_first_free(
  is_forward_sweep : Bool,
  length : Int,
) -> Int {
  if is_forward_sweep {
    1
  } else {
    length - 2
  }
}

///|
fn greedy_switch_processor_test_next(is_forward_sweep : Bool) -> Int {
  if is_forward_sweep {
    1
  } else {
    -1
  }
}

///|
fn greedy_switch_processor_test_is_not_end(
  length : Int,
  free_layer_index : Int,
  is_forward_sweep : Bool,
) -> Bool {
  if is_forward_sweep {
    free_layer_index < length
  } else {
    free_layer_index >= 0
  }
}

///|
fn greedy_switch_processor_test_sweep_reducing_crossings(
  node_order : Array[Array[LNode]],
  heuristic : GreedySwitchHeuristic,
  port_distributor : ISweepPortDistributor,
  is_forward_sweep : Bool,
  is_first_sweep : Bool,
) -> Bool {
  let length = node_order.length()
  if length <= 1 {
    return false
  }

  let mut improved = port_distributor.distribute_ports_while_sweeping(
    node_order,
    greedy_switch_processor_test_first_index(is_forward_sweep, length),
    is_forward_sweep,
  )

  let mut free_layer_index = greedy_switch_processor_test_first_free(
    is_forward_sweep, length,
  )
  while greedy_switch_processor_test_is_not_end(
          length, free_layer_index, is_forward_sweep,
        ) {
    improved = heuristic.minimize_crossings(
        node_order, free_layer_index, is_forward_sweep, is_first_sweep,
      ) ||
      improved
    improved = port_distributor.distribute_ports_while_sweeping(
        node_order, free_layer_index, is_forward_sweep,
      ) ||
      improved
    free_layer_index = free_layer_index +
      greedy_switch_processor_test_next(is_forward_sweep)
  }
  improved
}

///|
fn greedy_switch_processor_test_start_greedy_switcher(
  creator : GreedySwitchTestGraphCreator,
  greedy_type : GreedySwitchType,
) -> Unit {
  let graph = creator.get_graph()
  let node_order = creator.get_current_order(graph)
  let graph_data = new_graph_info_holder(node_order)
  let heuristic = new_greedy_switch_heuristic(greedy_type, graph_data)
  let port_distributor = new_greedy_port_distributor().as_i_sweep_port_distributor()
  let all_crossings_counter = new_all_crossings_counter(node_order)
  i_initializable_init(
    [
      port_distributor.as_initializable(),
      heuristic.as_initializable(),
      all_crossings_counter.as_initializable(),
    ],
    node_order,
  )

  if node_order.length() <= 1 {
    return
  }

  let mut is_forward_sweep = creator.get_random().next_boolean()
  if !greedy_switch_processor_test_is_one_sided(greedy_type) {
    let mut improved = true
    while improved {
      improved = false
      improved = heuristic.set_first_layer_order(node_order, is_forward_sweep) ||
        improved
      improved = greedy_switch_processor_test_sweep_reducing_crossings(
          node_order, heuristic, port_distributor, is_forward_sweep, false,
        ) ||
        improved
      is_forward_sweep = !is_forward_sweep
    }
    greedy_switch_processor_test_transfer_node_order_to_graph(graph, node_order)
    return
  }

  ignore(heuristic.set_first_layer_order(node_order, is_forward_sweep))
  ignore(
    greedy_switch_processor_test_sweep_reducing_crossings(
      node_order, heuristic, port_distributor, is_forward_sweep, true,
    ),
  )

  let mut crossings_in_graph = all_crossings_counter.count_all_crossings(
    node_order,
  )
  while true {
    if crossings_in_graph == 0 {
      greedy_switch_processor_test_transfer_node_order_to_graph(
        graph, node_order,
      )
      return
    }

    is_forward_sweep = !is_forward_sweep
    let best_snapshot = greedy_switch_processor_test_take_snapshot(node_order)
    let old_crossings = crossings_in_graph

    ignore(
      greedy_switch_processor_test_sweep_reducing_crossings(
        node_order, heuristic, port_distributor, is_forward_sweep, false,
      ),
    )
    crossings_in_graph = all_crossings_counter.count_all_crossings(node_order)

    if old_crossings <= crossings_in_graph {
      greedy_switch_processor_test_restore_snapshot(node_order, best_snapshot)
      greedy_switch_processor_test_transfer_node_order_to_graph(
        graph, node_order,
      )
      return
    }
  }
}

///|
test "GreedySwitchProcessor should_switch_cross" {
  for greedy_type in greedy_switch_processor_test_types() {
    let creator = new_greedy_switch_test_graph_creator()
    ignore(creator.get_cross_formed_graph())

    let (expected_order_layer_one, expected_order_layer_two) = if greedy_switch_processor_test_is_one_sided(
        greedy_type,
      ) {
      (
        creator.copy_of_nodes_in_layer(0),
        creator.copy_of_switch_order_of_nodes_in_layer(0, 1, 1),
      )
    } else {
      (
        creator.copy_of_switch_order_of_nodes_in_layer(0, 1, 0),
        creator.copy_of_nodes_in_layer(1),
      )
    }

    greedy_switch_processor_test_start_greedy_switcher(creator, greedy_type)

    greedy_switch_processor_test_assert_layer_order(
      creator.copy_of_nodes_in_layer(0),
      expected_order_layer_one,
    )
    greedy_switch_processor_test_assert_layer_order(
      creator.copy_of_nodes_in_layer(1),
      expected_order_layer_two,
    )
  }
}

///|
test "GreedySwitchProcessor constraints_prevent_switch_in_second_layer" {
  for greedy_type in greedy_switch_processor_test_types() {
    let creator = new_greedy_switch_test_graph_creator()
    ignore(creator.get_cross_formed_graph_with_constraints_in_second_layer())

    let expected_order_layer_one = creator.copy_of_switch_order_of_nodes_in_layer(
      0, 1, 0,
    )
    let expected_order_layer_two = creator.copy_of_nodes_in_layer(1)

    greedy_switch_processor_test_start_greedy_switcher(creator, greedy_type)

    greedy_switch_processor_test_assert_layer_order(
      creator.copy_of_nodes_in_layer(0),
      expected_order_layer_one,
    )
    greedy_switch_processor_test_assert_layer_order(
      creator.copy_of_nodes_in_layer(1),
      expected_order_layer_two,
    )
  }
}

///|
test "GreedySwitchProcessor constraints_prevent_any_switch" {
  for greedy_type in greedy_switch_processor_test_types() {
    let creator = new_greedy_switch_test_graph_creator()
    ignore(creator.get_cross_formed_graph_constraints_prevent_any_switch())

    let expected_order_layer_one = creator.copy_of_nodes_in_layer(0)
    let expected_order_layer_two = creator.copy_of_nodes_in_layer(1)

    greedy_switch_processor_test_start_greedy_switcher(creator, greedy_type)

    greedy_switch_processor_test_assert_layer_order(
      creator.copy_of_nodes_in_layer(0),
      expected_order_layer_one,
    )
    greedy_switch_processor_test_assert_layer_order(
      creator.copy_of_nodes_in_layer(1),
      expected_order_layer_two,
    )
  }
}

///|
test "GreedySwitchProcessor layout_unit_constraint_prevents_switch" {
  for greedy_type in greedy_switch_processor_test_types() {
    let creator = new_greedy_switch_test_graph_creator()
    ignore(creator.get_nodes_in_different_layout_units_prevent_switch())

    let expected_order_layer_two = creator.copy_of_nodes_in_layer(1)

    greedy_switch_processor_test_start_greedy_switcher(creator, greedy_type)

    greedy_switch_processor_test_assert_layer_order(
      creator.copy_of_nodes_in_layer(1),
      expected_order_layer_two,
    )
  }
}

///|
test "GreedySwitchProcessor one_node" {
  for greedy_type in greedy_switch_processor_test_types() {
    let creator = new_greedy_switch_test_graph_creator()
    ignore(creator.get_one_node_graph())
    ignore(creator.copy_of_switch_order_of_nodes_in_layer(0, 0, 0))
    greedy_switch_processor_test_start_greedy_switcher(creator, greedy_type)
  }
}

///|
test "GreedySwitchProcessor in_layer_switchable" {
  for greedy_type in greedy_switch_processor_test_types() {
    let creator = new_greedy_switch_test_graph_creator()
    ignore(creator.get_in_layer_edges_graph())

    let expected_order = creator.copy_of_switch_order_of_nodes_in_layer(0, 1, 1)

    greedy_switch_processor_test_start_greedy_switcher(creator, greedy_type)

    greedy_switch_processor_test_assert_layer_order(
      creator.copy_of_nodes_in_layer(1),
      expected_order,
    )
  }
}

///|
test "GreedySwitchProcessor multiple_edges_between_same_nodes" {
  for greedy_type in greedy_switch_processor_test_types() {
    let creator = new_greedy_switch_test_graph_creator()
    ignore(creator.get_multiple_edges_between_same_nodes_graph())

    let (expected_order_layer_one, expected_order_layer_two) = if greedy_switch_processor_test_is_one_sided(
        greedy_type,
      ) {
      (
        creator.copy_of_nodes_in_layer(0),
        creator.copy_of_switch_order_of_nodes_in_layer(0, 1, 1),
      )
    } else {
      (
        creator.copy_of_switch_order_of_nodes_in_layer(0, 1, 0),
        creator.copy_of_nodes_in_layer(1),
      )
    }

    greedy_switch_processor_test_start_greedy_switcher(creator, greedy_type)

    greedy_switch_processor_test_assert_layer_order(
      creator.copy_of_nodes_in_layer(0),
      expected_order_layer_one,
    )
    greedy_switch_processor_test_assert_layer_order(
      creator.copy_of_nodes_in_layer(1),
      expected_order_layer_two,
    )
  }
}

///|
test "GreedySwitchProcessor self_loops" {
  for greedy_type in greedy_switch_processor_test_types() {
    let creator = new_greedy_switch_test_graph_creator()

    let left_layer = creator.make_layer(creator.get_graph())
    let right_layer = creator.make_layer(creator.get_graph())

    let top_left = creator.add_node_to_layer(left_layer)
    let bottom_left = creator.add_node_to_layer(left_layer)
    let top_right = creator.add_node_to_layer(right_layer)
    let bottom_right = creator.add_node_to_layer(right_layer)

    let top_left_port = creator.add_port_on_side(top_left, @core.PortSide::East)
    let bottom_left_port = creator.add_port_on_side(
      bottom_left,
      @core.PortSide::East,
    )
    creator.set_up_ids()

    let self_loop_cross_graph = creator.get_graph()
    for layer in self_loop_cross_graph.get_layers() {
      for node in layer.get_nodes() {
        creator.self_loop_on(node, @core.PortSide::East)
        creator.self_loop_on(node, @core.PortSide::East)
        creator.self_loop_on(node, @core.PortSide::East)
        creator.self_loop_on(node, @core.PortSide::West)
        creator.self_loop_on(node, @core.PortSide::West)
        creator.self_loop_on(node, @core.PortSide::West)
      }
    }

    let top_right_port = creator.add_port_on_side(
      top_right,
      @core.PortSide::West,
    )
    let bottom_right_port = creator.add_port_on_side(
      bottom_right,
      @core.PortSide::West,
    )

    creator.add_edge_between_ports(top_left_port, bottom_right_port)
    creator.add_edge_between_ports(bottom_left_port, top_right_port)

    let (expected_order_layer_one, expected_order_layer_two) = if greedy_switch_processor_test_is_one_sided(
        greedy_type,
      ) {
      (
        creator.copy_of_nodes_in_layer(0),
        creator.copy_of_switch_order_of_nodes_in_layer(0, 1, 1),
      )
    } else {
      (
        creator.copy_of_switch_order_of_nodes_in_layer(0, 1, 0),
        creator.copy_of_nodes_in_layer(1),
      )
    }

    greedy_switch_processor_test_start_greedy_switcher(creator, greedy_type)

    greedy_switch_processor_test_assert_layer_order(
      creator.copy_of_nodes_in_layer(0),
      expected_order_layer_one,
    )
    greedy_switch_processor_test_assert_layer_order(
      creator.copy_of_nodes_in_layer(1),
      expected_order_layer_two,
    )
  }
}

///|
test "GreedySwitchProcessor north_south_port_crossing" {
  for greedy_type in greedy_switch_processor_test_types() {
    let creator = new_greedy_switch_test_graph_creator()
    let graph = new_greedy_switch_north_south_edge_test_graph_creator().get_north_south_downward_crossing_graph()
    ignore(creator.set_graph(graph))

    let layer_index = 0
    let expected_order_two_sided = creator.copy_of_nodes_in_layer(layer_index)
    let expected_order_one_sided = creator.copy_of_switch_order_of_nodes_in_layer(
      1, 2, layer_index,
    )

    greedy_switch_processor_test_start_greedy_switcher(creator, greedy_type)

    if greedy_switch_processor_test_is_one_sided(greedy_type) {
      greedy_switch_processor_test_assert_layer_order(
        creator.copy_of_nodes_in_layer(layer_index),
        expected_order_one_sided,
      )
    } else {
      greedy_switch_processor_test_assert_layer_order(
        creator.copy_of_nodes_in_layer(layer_index),
        expected_order_two_sided,
      )
    }
  }
}

///|
test "GreedySwitchProcessor more_complex" {
  for greedy_type in greedy_switch_processor_test_types() {
    let creator = new_greedy_switch_test_graph_creator()
    ignore(creator.get_more_complex_three_layer_graph())

    let expected_order_layer_two = creator.copy_of_nodes_in_layer(1)
    let expected_order_layer_three = creator.copy_of_switch_order_of_nodes_in_layer(
      0, 1, 2,
    )

    greedy_switch_processor_test_start_greedy_switcher(creator, greedy_type)

    greedy_switch_processor_test_assert_layer_order(
      creator.copy_of_nodes_in_layer(1),
      expected_order_layer_two,
    )
    greedy_switch_processor_test_assert_layer_order(
      creator.copy_of_nodes_in_layer(2),
      expected_order_layer_three,
    )
  }
}

///|
test "GreedySwitchProcessor switch_only_for_one_sided" {
  for greedy_type in greedy_switch_processor_test_types() {
    let creator = new_greedy_switch_test_graph_creator()
    ignore(creator.get_switch_only_one_sided())

    let layer_index = 1
    let expected_order_one_sided = creator.copy_of_switch_order_of_nodes_in_layer(
      0, 1, layer_index,
    )
    let expected_order_two_sided = creator.copy_of_nodes_in_layer(layer_index)

    greedy_switch_processor_test_start_greedy_switcher(creator, greedy_type)

    if greedy_switch_processor_test_is_one_sided(greedy_type) {
      greedy_switch_processor_test_assert_layer_order(
        creator.copy_of_nodes_in_layer(layer_index),
        expected_order_one_sided,
      )
    } else {
      greedy_switch_processor_test_assert_layer_order(
        creator.copy_of_nodes_in_layer(layer_index),
        expected_order_two_sided,
      )
    }
  }
}

///|
test "GreedySwitchProcessor does_not_worsen_cross_amount" {
  for greedy_type in greedy_switch_processor_test_types() {
    let creator = new_greedy_switch_test_graph_creator()
    ignore(creator.get_graph_which_could_be_worsened_by_switch())

    let expected_order_first_layer = creator.copy_of_nodes_in_layer(0)
    let expected_order_second_layer = creator.copy_of_nodes_in_layer(1)

    greedy_switch_processor_test_start_greedy_switcher(creator, greedy_type)

    greedy_switch_processor_test_assert_layer_order(
      creator.copy_of_nodes_in_layer(0),
      expected_order_first_layer,
    )
    greedy_switch_processor_test_assert_layer_order(
      creator.copy_of_nodes_in_layer(1),
      expected_order_second_layer,
    )
  }
}

///|
test "GreedySwitchProcessor switch_more_than_once" {
  for greedy_type in greedy_switch_processor_test_types() {
    let creator = new_greedy_switch_test_graph_creator()
    let left_nodes = creator.add_nodes_to_layer(
      2,
      creator.make_layer(creator.get_graph()),
    )
    let right_nodes = creator.add_nodes_to_layer(
      4,
      creator.make_layer(creator.get_graph()),
    )
    let left_top_port = creator.add_port_on_side(
      left_nodes[0],
      @core.PortSide::East,
    )
    let left_lower_port = creator.add_port_on_side(
      left_nodes[1],
      @core.PortSide::East,
    )
    let right_top_port = creator.add_port_on_side(
      right_nodes[0],
      @core.PortSide::West,
    )

    creator.add_edge_between_ports(left_lower_port, right_top_port)
    creator.east_west_edge_from_to_port_node(left_lower_port, right_nodes[2])

    creator.add_edge_between_ports(left_top_port, right_top_port)
    creator.east_west_edge_from_to_port_node(left_top_port, right_nodes[1])
    creator.east_west_edge_from_to_port_node(left_top_port, right_nodes[3])
    creator.set_up_ids()

    let one_sided_first_layer = creator.copy_of_nodes_in_layer(0)
    let one_sided_first_switch_second_layer = creator.copy_of_switch_order_of_nodes_in_layer(
      0, 1, 1,
    )
    let one_sided_second_switch_second_layer = creator.get_copy_with_switched_order(
      2, 3, one_sided_first_switch_second_layer,
    )
    let one_sided_third_switch_second_layer = creator.get_copy_with_switched_order(
      1, 2, one_sided_second_switch_second_layer,
    )

    let two_sided_first_layer = creator.copy_of_switch_order_of_nodes_in_layer(
      0, 1, 0,
    )
    let two_sided_first_switch_second_layer = creator.copy_of_switch_order_of_nodes_in_layer(
      1, 2, 1,
    )
    let two_sided_second_switch_second_layer = creator.get_copy_with_switched_order(
      0, 1, two_sided_first_switch_second_layer,
    )

    greedy_switch_processor_test_start_greedy_switcher(creator, greedy_type)
    if greedy_switch_processor_test_is_one_sided(greedy_type) {
      greedy_switch_processor_test_assert_layer_order(
        creator.copy_of_nodes_in_layer(0),
        one_sided_first_layer,
      )
      greedy_switch_processor_test_assert_layer_order(
        creator.copy_of_nodes_in_layer(1),
        one_sided_third_switch_second_layer,
      )
    } else {
      greedy_switch_processor_test_assert_layer_order(
        creator.copy_of_nodes_in_layer(0),
        two_sided_first_layer,
      )
      greedy_switch_processor_test_assert_layer_order(
        creator.copy_of_nodes_in_layer(1),
        two_sided_second_switch_second_layer,
      )
    }
  }
}
