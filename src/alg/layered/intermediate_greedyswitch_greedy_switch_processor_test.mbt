///|
fn greedy_switch_processor_test_cross_types() -> Array[CrossMinType] {
  let cross_types = cross_min_type_constants()
  [cross_types[1], cross_types[2]]
}

///|
fn greedy_switch_processor_test_is_one_sided(cross_type : CrossMinType) -> Bool {
  match cross_type {
    CrossMinType::OneSidedGreedySwitch => true
    _ => false
  }
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
fn greedy_switch_processor_test_run(
  creator : GreedySwitchTestGraphCreator,
  cross_type : CrossMinType,
) -> Unit {
  let minimizer = new_layer_sweep_crossing_minimizer(cross_type)
  minimizer.process(
    creator.get_graph(),
    progress_monitor=Some(new_basic_progress_monitor()),
  )
}

///|
fn greedy_switch_processor_test_horizontal_sides() -> (
  @core.PortSide,
  @core.PortSide,
) {
  let creator = new_greedy_switch_test_graph_creator()
  let layers = creator.make_layers(2)
  let left = creator.add_node_to_layer(layers[0])
  let right = creator.add_node_to_layer(layers[1])
  creator.east_west_edge_from_to_nodes(left, right)
  (left.get_ports()[0].get_side(), right.get_ports()[0].get_side())
}

///|
test "GreedySwitchProcessor should switch crossed graph according to mode" {
  for cross_type in greedy_switch_processor_test_cross_types() {
    let creator = new_greedy_switch_test_graph_creator()
    ignore(creator.get_cross_formed_graph())

    let (expected_layer_one, expected_layer_two) = if greedy_switch_processor_test_is_one_sided(
        cross_type,
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

    greedy_switch_processor_test_run(creator, cross_type)

    greedy_switch_processor_test_assert_layer_order(
      creator.copy_of_nodes_in_layer(0),
      expected_layer_one,
    )
    greedy_switch_processor_test_assert_layer_order(
      creator.copy_of_nodes_in_layer(1),
      expected_layer_two,
    )
  }
}

///|
test "GreedySwitchProcessor constraints prevent switch in second layer" {
  for cross_type in greedy_switch_processor_test_cross_types() {
    let creator = new_greedy_switch_test_graph_creator()
    ignore(creator.get_cross_formed_graph_with_constraints_in_second_layer())

    let expected_layer_one = creator.copy_of_switch_order_of_nodes_in_layer(
      0, 1, 0,
    )
    let expected_layer_two = creator.copy_of_nodes_in_layer(1)

    greedy_switch_processor_test_run(creator, cross_type)

    greedy_switch_processor_test_assert_layer_order(
      creator.copy_of_nodes_in_layer(0),
      expected_layer_one,
    )
    greedy_switch_processor_test_assert_layer_order(
      creator.copy_of_nodes_in_layer(1),
      expected_layer_two,
    )
  }
}

///|
test "GreedySwitchProcessor respects constraints preventing all switches" {
  for cross_type in greedy_switch_processor_test_cross_types() {
    let creator = new_greedy_switch_test_graph_creator()
    ignore(creator.get_cross_formed_graph_constraints_prevent_any_switch())

    let expected_layer_one = creator.copy_of_nodes_in_layer(0)
    let expected_layer_two = creator.copy_of_nodes_in_layer(1)

    greedy_switch_processor_test_run(creator, cross_type)

    greedy_switch_processor_test_assert_layer_order(
      creator.copy_of_nodes_in_layer(0),
      expected_layer_one,
    )
    greedy_switch_processor_test_assert_layer_order(
      creator.copy_of_nodes_in_layer(1),
      expected_layer_two,
    )
  }
}

///|
test "GreedySwitchProcessor respects layout-unit constraint preventing switch" {
  for cross_type in greedy_switch_processor_test_cross_types() {
    let creator = new_greedy_switch_test_graph_creator()
    ignore(creator.get_nodes_in_different_layout_units_prevent_switch())

    let expected_layer_two = creator.copy_of_nodes_in_layer(1)

    greedy_switch_processor_test_run(creator, cross_type)

    greedy_switch_processor_test_assert_layer_order(
      creator.copy_of_nodes_in_layer(1),
      expected_layer_two,
    )
  }
}

///|
test "GreedySwitchProcessor handles one-node graph" {
  for cross_type in greedy_switch_processor_test_cross_types() {
    let creator = new_greedy_switch_test_graph_creator()
    ignore(creator.get_one_node_graph())
    ignore(creator.copy_of_switch_order_of_nodes_in_layer(0, 0, 0))
    greedy_switch_processor_test_run(creator, cross_type)
  }
}

///|
test "GreedySwitchProcessor switches in-layer edges graph" {
  for cross_type in greedy_switch_processor_test_cross_types() {
    let creator = new_greedy_switch_test_graph_creator()
    ignore(creator.get_in_layer_edges_graph())

    let expected_order = creator.copy_of_switch_order_of_nodes_in_layer(0, 1, 1)

    greedy_switch_processor_test_run(creator, cross_type)

    greedy_switch_processor_test_assert_layer_order(
      creator.copy_of_nodes_in_layer(1),
      expected_order,
    )
  }
}

///|
test "GreedySwitchProcessor handles multiple edges between same nodes" {
  for cross_type in greedy_switch_processor_test_cross_types() {
    let creator = new_greedy_switch_test_graph_creator()
    ignore(creator.get_multiple_edges_between_same_nodes_graph())

    let (expected_layer_one, expected_layer_two) = if greedy_switch_processor_test_is_one_sided(
        cross_type,
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

    greedy_switch_processor_test_run(creator, cross_type)

    greedy_switch_processor_test_assert_layer_order(
      creator.copy_of_nodes_in_layer(0),
      expected_layer_one,
    )
    greedy_switch_processor_test_assert_layer_order(
      creator.copy_of_nodes_in_layer(1),
      expected_layer_two,
    )
  }
}

///|
test "GreedySwitchProcessor handles self loops" {
  for cross_type in greedy_switch_processor_test_cross_types() {
    let creator = new_greedy_switch_test_graph_creator()
    let (east_side, west_side) = greedy_switch_processor_test_horizontal_sides()

    let left_layer = creator.make_layer(creator.get_graph())
    let right_layer = creator.make_layer(creator.get_graph())

    let top_left = creator.add_node_to_layer(left_layer)
    let bottom_left = creator.add_node_to_layer(left_layer)
    let top_right = creator.add_node_to_layer(right_layer)
    let bottom_right = creator.add_node_to_layer(right_layer)

    let top_left_port = creator.add_port_on_side(top_left, east_side)
    let bottom_left_port = creator.add_port_on_side(bottom_left, east_side)
    creator.set_up_ids()

    let self_loop_cross_graph = creator.get_graph()
    for layer in self_loop_cross_graph.get_layers() {
      for node in layer.get_nodes() {
        creator.self_loop_on(node, east_side)
        creator.self_loop_on(node, east_side)
        creator.self_loop_on(node, east_side)
        creator.self_loop_on(node, west_side)
        creator.self_loop_on(node, west_side)
        creator.self_loop_on(node, west_side)
      }
    }

    let top_right_port = creator.add_port_on_side(top_right, west_side)
    let bottom_right_port = creator.add_port_on_side(bottom_right, west_side)

    creator.add_edge_between_ports(top_left_port, bottom_right_port)
    creator.add_edge_between_ports(bottom_left_port, top_right_port)

    let (expected_layer_one, expected_layer_two) = if greedy_switch_processor_test_is_one_sided(
        cross_type,
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

    greedy_switch_processor_test_run(creator, cross_type)

    greedy_switch_processor_test_assert_layer_order(
      creator.copy_of_nodes_in_layer(0),
      expected_layer_one,
    )
    greedy_switch_processor_test_assert_layer_order(
      creator.copy_of_nodes_in_layer(1),
      expected_layer_two,
    )
  }
}

///|
test "GreedySwitchProcessor handles north-south port crossing by mode" {
  for cross_type in greedy_switch_processor_test_cross_types() {
    let creator = new_greedy_switch_test_graph_creator()
    let graph = new_greedy_switch_north_south_edge_test_graph_creator().get_north_south_downward_crossing_graph()
    ignore(creator.set_graph(graph))

    let layer_index = 0
    let expected_order_two_sided = creator.copy_of_nodes_in_layer(layer_index)
    let expected_order_one_sided = creator.copy_of_switch_order_of_nodes_in_layer(
      1, 2, layer_index,
    )

    greedy_switch_processor_test_run(creator, cross_type)

    if greedy_switch_processor_test_is_one_sided(cross_type) {
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
test "GreedySwitchProcessor handles more complex three-layer graph" {
  for cross_type in greedy_switch_processor_test_cross_types() {
    let creator = new_greedy_switch_test_graph_creator()
    ignore(creator.get_more_complex_three_layer_graph())

    let expected_order_layer_two = creator.copy_of_nodes_in_layer(1)
    let expected_order_layer_three = creator.copy_of_switch_order_of_nodes_in_layer(
      0, 1, 2,
    )

    greedy_switch_processor_test_run(creator, cross_type)

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
test "GreedySwitchProcessor switches only for one-sided mode in specific graph" {
  for cross_type in greedy_switch_processor_test_cross_types() {
    let creator = new_greedy_switch_test_graph_creator()
    ignore(creator.get_switch_only_one_sided())

    let layer_index = 1
    let expected_order_one_sided = creator.copy_of_switch_order_of_nodes_in_layer(
      0, 1, layer_index,
    )
    let expected_order_two_sided = creator.copy_of_nodes_in_layer(layer_index)

    greedy_switch_processor_test_run(creator, cross_type)

    if greedy_switch_processor_test_is_one_sided(cross_type) {
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
test "GreedySwitchProcessor does not worsen cross amount" {
  for cross_type in greedy_switch_processor_test_cross_types() {
    let creator = new_greedy_switch_test_graph_creator()
    ignore(creator.get_graph_which_could_be_worsened_by_switch())

    let expected_order_first_layer = creator.copy_of_nodes_in_layer(0)
    let expected_order_second_layer = creator.copy_of_nodes_in_layer(1)

    greedy_switch_processor_test_run(creator, cross_type)

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
test "GreedySwitchProcessor can switch more than once in one run" {
  for cross_type in greedy_switch_processor_test_cross_types() {
    let creator = new_greedy_switch_test_graph_creator()
    let (east_side, west_side) = greedy_switch_processor_test_horizontal_sides()
    let left_nodes = creator.add_nodes_to_layer(
      2,
      creator.make_layer(creator.get_graph()),
    )
    let right_nodes = creator.add_nodes_to_layer(
      4,
      creator.make_layer(creator.get_graph()),
    )
    let left_top_port = creator.add_port_on_side(left_nodes[0], east_side)
    let left_lower_port = creator.add_port_on_side(left_nodes[1], east_side)
    let right_top_port = creator.add_port_on_side(right_nodes[0], west_side)

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

    greedy_switch_processor_test_run(creator, cross_type)
    if greedy_switch_processor_test_is_one_sided(cross_type) {
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
