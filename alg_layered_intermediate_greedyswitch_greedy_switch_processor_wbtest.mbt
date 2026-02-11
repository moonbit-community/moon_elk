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
fn greedy_switch_processor_test_assert_layer_order(
  actual : Array[LNode],
  expected : Array[LNode],
) -> Unit {
  let actual_handles = greedy_switch_processor_test_node_handles(actual)
  let expected_handles = greedy_switch_processor_test_node_handles(expected)
  if actual_handles != expected_handles {
    abort("unexpected layer order")
  }
}

///|
fn greedy_switch_processor_test_start_greedy_switcher(
  creator : GreedySwitchTestGraphCreator,
  greedy_type : GreedySwitchType,
) -> Unit {
  let node_order = creator.get_current_order(creator.get_graph())
  let graph_data = new_graph_info_holder(node_order)
  let heuristic = new_greedy_switch_heuristic(greedy_type, graph_data)
  i_initializable_init([heuristic.as_initializable()], node_order)

  if node_order.length() <= 1 {
    return
  }

  let mut is_forward_sweep = true
  let mut improved = true
  let mut rounds = 0
  while improved && rounds < 8 {
    improved = false
    improved = heuristic.set_first_layer_order(node_order, is_forward_sweep) ||
      improved

    if is_forward_sweep {
      for free_layer_index in 1..<node_order.length() {
        improved = heuristic.minimize_crossings(
            node_order,
            free_layer_index,
            true,
            rounds == 0,
          ) ||
          improved
      }
    } else {
      let mut free_layer_index = node_order.length() - 2
      while true {
        improved = heuristic.minimize_crossings(
            node_order,
            free_layer_index,
            false,
            rounds == 0,
          ) ||
          improved
        if free_layer_index == 0 {
          break
        }
        free_layer_index = free_layer_index - 1
      }
    }

    if greedy_switch_processor_test_is_one_sided(greedy_type) {
      // One-sided mode in ELK uses counters and can stop without full oscillation.
      if !improved || rounds > 1 {
        break
      }
    }
    rounds = rounds + 1
    is_forward_sweep = !is_forward_sweep
  }
}

///|
fn greedy_switch_processor_pending_should_switch_cross() -> Unit {
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
fn greedy_switch_processor_pending_constraints_prevent_switch_in_second_layer() -> Unit {
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
fn greedy_switch_processor_pending_in_layer_switchable() -> Unit {
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
fn greedy_switch_processor_pending_multiple_edges_between_same_nodes() -> Unit {
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
fn greedy_switch_processor_pending_self_loops() -> Unit {
  for greedy_type in greedy_switch_processor_test_types() {
    let creator = new_greedy_switch_test_graph_creator()

    let left_layer = creator.make_layer(creator.get_graph())
    let right_layer = creator.make_layer(creator.get_graph())

    let top_left = creator.add_node_to_layer(left_layer)
    let bottom_left = creator.add_node_to_layer(left_layer)
    let top_right = creator.add_node_to_layer(right_layer)
    let bottom_right = creator.add_node_to_layer(right_layer)

    let top_left_port = creator.add_port_on_side(top_left, PortSide::East)
    let bottom_left_port = creator.add_port_on_side(bottom_left, PortSide::East)
    creator.set_up_ids()

    let self_loop_cross_graph = creator.get_graph()
    for layer in self_loop_cross_graph.get_layers() {
      for node in layer.get_nodes() {
        creator.self_loop_on(node, PortSide::East)
        creator.self_loop_on(node, PortSide::East)
        creator.self_loop_on(node, PortSide::East)
        creator.self_loop_on(node, PortSide::West)
        creator.self_loop_on(node, PortSide::West)
        creator.self_loop_on(node, PortSide::West)
      }
    }

    let top_right_port = creator.add_port_on_side(top_right, PortSide::West)
    let bottom_right_port = creator.add_port_on_side(
      bottom_right,
      PortSide::West,
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
fn greedy_switch_processor_pending_north_south_port_crossing() -> Unit {
  for greedy_type in greedy_switch_processor_test_types() {
    let creator = new_greedy_switch_test_graph_creator()
    let graph = new_greedy_switch_north_south_edge_test_graph_creator().get_north_south_downward_crossing_graph()
    ignore(creator.set_up_graph(graph))

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
fn greedy_switch_processor_pending_more_complex() -> Unit {
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
fn greedy_switch_processor_pending_switch_only_for_one_sided() -> Unit {
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
fn greedy_switch_processor_pending_switch_more_than_once() -> Unit {
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
    let left_top_port = creator.add_port_on_side(left_nodes[0], PortSide::East)
    let left_lower_port = creator.add_port_on_side(
      left_nodes[1],
      PortSide::East,
    )
    let right_top_port = creator.add_port_on_side(
      right_nodes[0],
      PortSide::West,
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
