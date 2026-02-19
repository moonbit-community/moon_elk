///|
fn layer_sweep_test_cross_types() -> Array[CrossMinType] {
  let values = cross_min_type_constants()
  [values[0], values[1]]
}

///|
fn layer_sweep_test_node_handles(nodes : Array[LNode]) -> Array[Int] {
  let handles = []
  for node in nodes {
    handles.push(node.get_handle())
  }
  handles
}

///|
fn layer_sweep_test_port_handles(ports : Array[LPort]) -> Array[Int] {
  let handles = []
  for port in ports {
    handles.push(port.get_handle())
  }
  handles
}

///|
fn layer_sweep_test_east() -> PortSide {
  port_side_values()[2]
}

///|
fn layer_sweep_test_west() -> PortSide {
  port_side_values()[4]
}

///|
fn layer_sweep_test_north() -> PortSide {
  port_side_values()[1]
}

///|
fn layer_sweep_test_south() -> PortSide {
  port_side_values()[3]
}

///|
fn layer_sweep_test_pop_graph(graphs : Array[LGraph]) -> LGraph {
  match graphs.pop() {
    Some(graph) => graph
    None => abort("graph stack is empty")
  }
}

///|
fn layer_sweep_test_set_on_all_graphs(
  root : LGraph,
  property : IProperty[Double],
  value : Double,
) -> Unit {
  let graphs = [root]
  while !graphs.is_empty() {
    let graph = layer_sweep_test_pop_graph(graphs)
    graph.set_property_double(property, value)
    for layer in graph.get_layers() {
      for node in layer.get_nodes() {
        match node.get_nested_graph() {
          Some(nested) => graphs.push(nested)
          None => ()
        }
      }
    }
  }
}

///|
fn layer_sweep_test_reverse_ports(ports : Array[LPort]) -> Array[LPort] {
  let reversed = []
  for index in 0..<ports.length() {
    reversed.push(ports[ports.length() - 1 - index])
  }
  reversed
}

///|
fn layer_sweep_test_nodes_in_order(
  first_node : LNode,
  second_node : LNode,
  layer : Layer,
) -> Bool {
  let first_handle = first_node.get_handle()
  let second_handle = second_node.get_handle()
  for node in layer.get_nodes() {
    let handle = node.get_handle()
    if handle == first_handle {
      return true
    } else if handle == second_handle {
      return false
    }
  }
  false
}

///|
fn layer_sweep_test_make_nested_two_node_graph_with_western_ports(
  creator : TestGraphCreator,
  right_outer_node : LNode,
  right_outer_ports : Array[LPort],
) -> LGraph {
  let right_inner_graph = creator.nested_graph(right_outer_node)
  let right_inner_dummy_nodes = creator.add_external_port_dummies_to_layer(
    creator.make_layer(right_inner_graph),
    right_outer_ports,
  )
  let right_inner_nodes = creator.add_nodes_to_layer(
    2,
    creator.make_layer(right_inner_graph),
  )
  creator.east_west_edge_from_to_nodes(
    right_inner_dummy_nodes[0],
    right_inner_nodes[0],
  )
  creator.east_west_edge_from_to_nodes(
    right_inner_dummy_nodes[1],
    right_inner_nodes[1],
  )
  right_inner_graph
}

///|
fn layer_sweep_test_make_nested_two_node_graph_with_eastern_ports(
  creator : TestGraphCreator,
  left_outer_node : LNode,
  left_outer_ports : Array[LPort],
) -> LGraph {
  let left_inner_graph = creator.nested_graph(left_outer_node)
  let left_inner_nodes = creator.add_nodes_to_layer(
    2,
    creator.make_layer(left_inner_graph),
  )
  let left_inner_dummy_nodes = creator.add_external_port_dummies_to_layer(
    creator.make_layer(left_inner_graph),
    left_outer_ports,
  )
  creator.east_west_edge_from_to_nodes(
    left_inner_nodes[0],
    left_inner_dummy_nodes[0],
  )
  creator.east_west_edge_from_to_nodes(
    left_inner_nodes[1],
    left_inner_dummy_nodes[1],
  )
  left_inner_graph
}

///|
fn layer_sweep_test_run(
  creator : TestGraphCreator,
  cross_min_type : CrossMinType,
) -> Unit {
  let cross_min = new_layer_sweep_crossing_minimizer(cross_min_type)
  cross_min.process(
    creator.get_graph(),
    progress_monitor=Some(new_basic_progress_monitor()),
  )
}

///|
fn layer_sweep_test_run_and_get_cross_min(
  creator : TestGraphCreator,
  cross_min_type : CrossMinType,
) -> LayerSweepCrossingMinimizer {
  let cross_min = new_layer_sweep_crossing_minimizer(cross_min_type)
  cross_min.process(
    creator.get_graph(),
    progress_monitor=Some(new_basic_progress_monitor()),
  )
  cross_min
}

///|
fn layer_sweep_test_assert_nested_graphs_not_marked_dont_sweep(
  graph_data : Array[GraphInfoHolder],
) -> Unit {
  for data in graph_data {
    if data.has_parent() && data.dont_sweep_into() {
      abort("unexpected dont_sweep_into on nested graph")
    }
  }
}

///|
test "LayerSweep given one node should not crash" {
  for cross_min_type in layer_sweep_test_cross_types() {
    let creator = new_test_graph_creator()
    let graph = creator.get_one_node_graph()
    let cross_min = new_layer_sweep_crossing_minimizer(cross_min_type)
    cross_min.process(
      graph,
      progress_monitor=Some(new_basic_progress_monitor()),
    )
  }
}

///|
test "LayerSweep given no node should not crash" {
  for cross_min_type in layer_sweep_test_cross_types() {
    let creator = new_test_graph_creator()
    let graph = creator.get_empty_graph()
    let cross_min = new_layer_sweep_crossing_minimizer(cross_min_type)
    cross_min.process(
      graph,
      progress_monitor=Some(new_basic_progress_monitor()),
    )
  }
}

///|
test "LayerSweep removes simple crossing in two-layer graph" {
  for cross_min_type in layer_sweep_test_cross_types() {
    let creator = new_test_graph_creator()
    let graph = creator.get_cross_formed_graph()
    let expected_right_order = creator.switch_order_of_nodes_in_layer(
      0,
      1,
      graph.get_layers()[1],
    )

    layer_sweep_test_run(creator, cross_min_type)

    assert_eq(
      layer_sweep_test_node_handles(graph.get_layers()[1].get_nodes()),
      layer_sweep_test_node_handles(expected_right_order),
    )
  }
}

///|
test "LayerSweep removes crossing inside single hierarchical node" {
  for cross_min_type in layer_sweep_test_cross_types() {
    let creator = new_test_graph_creator()
    let node = creator.add_node_to_layer(
      creator.make_layer(creator.get_graph()),
    )
    let inner_graph = creator.nested_graph(node)
    let left_nodes = creator.add_nodes_to_layer(
      2,
      creator.make_layer(inner_graph),
    )
    let right_nodes = creator.add_nodes_to_layer(
      2,
      creator.make_layer(inner_graph),
    )
    creator.east_west_edge_from_to_nodes(left_nodes[0], right_nodes[1])
    creator.east_west_edge_from_to_nodes(left_nodes[1], right_nodes[0])

    let expected_right_order = creator.switch_order_of_nodes_in_layer(
      0,
      1,
      inner_graph.get_layers()[1],
    )

    layer_sweep_test_run(creator, cross_min_type)

    assert_eq(
      layer_sweep_test_node_handles(inner_graph.get_layers()[1].get_nodes()),
      layer_sweep_test_node_handles(expected_right_order),
    )
  }
}

///|
test "LayerSweep forward sweep can fix compound inner order and port order" {
  for cross_min_type in layer_sweep_test_cross_types() {
    let creator = new_test_graph_creator()
    let node = creator.add_node_to_layer(
      creator.make_layer(creator.get_graph()),
    )
    let inner_graph = creator.nested_graph(node)
    let left_inner_node = creator.add_node_to_layer(
      creator.make_layer(inner_graph),
    )
    creator.set_fixed_order_constraint(left_inner_node)
    let right_inner_nodes = creator.add_nodes_to_layer(
      2,
      creator.make_layer(inner_graph),
    )
    creator.east_west_edge_from_to_nodes(left_inner_node, right_inner_nodes[1])
    creator.east_west_edge_from_to_nodes(left_inner_node, right_inner_nodes[0])

    let right_inner_layer = inner_graph.get_layers()[1]
    let expected_right_order = creator.switch_order_of_nodes_in_layer(
      0, 1, right_inner_layer,
    )
    let expected_left_port_order = creator.copy_ports_in_index_order(
      left_inner_node,
      [0, 1],
    )

    creator.get_random().set_next_boolean(false)
    layer_sweep_test_run(creator, cross_min_type)

    assert_eq(
      layer_sweep_test_port_handles(left_inner_node.get_ports()),
      layer_sweep_test_port_handles(expected_left_port_order),
    )
    assert_eq(
      layer_sweep_test_node_handles(right_inner_layer.get_nodes()),
      layer_sweep_test_node_handles(expected_right_order),
    )
  }
}

///|
test "LayerSweep backward sweep resolves simple hierarchical cross" {
  for cross_min_type in layer_sweep_test_cross_types() {
    let creator = new_test_graph_creator()
    let left_outer_node = creator.add_node_to_layer(
      creator.make_layer(creator.get_graph()),
    )
    let right_outer_node = creator.add_node_to_layer(
      creator.make_layer(creator.get_graph()),
    )
    let left_outer_ports = creator.add_ports_on_side(
      2,
      left_outer_node,
      layer_sweep_test_east(),
    )
    let right_outer_ports = creator.add_ports_on_side(
      2,
      right_outer_node,
      layer_sweep_test_west(),
    )
    creator.add_edge_between_ports(left_outer_ports[0], right_outer_ports[0])
    creator.add_edge_between_ports(left_outer_ports[1], right_outer_ports[1])

    let left_inner_graph = layer_sweep_test_make_nested_two_node_graph_with_eastern_ports(
      creator, left_outer_node, left_outer_ports,
    )
    ignore(
      layer_sweep_test_make_nested_two_node_graph_with_western_ports(
        creator, right_outer_node, right_outer_ports,
      ),
    )

    let expected_left_node_order = creator.switch_order_of_nodes_in_layer(
      0,
      1,
      left_inner_graph.get_layers()[0],
    )
    let expected_left_port_order = creator.get_list_copy_in_index_order(
      left_outer_ports,
      [1, 0],
    )

    creator.get_random().set_next_boolean(false)
    layer_sweep_test_run(creator, cross_min_type)

    assert_eq(
      layer_sweep_test_port_handles(left_outer_node.get_ports()),
      layer_sweep_test_port_handles(expected_left_port_order),
    )
    assert_eq(
      layer_sweep_test_node_handles(
        left_inner_graph.get_layers()[0].get_nodes(),
      ),
      layer_sweep_test_node_handles(expected_left_node_order),
    )
  }
}

///|
test "LayerSweep keeps backward-sweep candidate when it improves middle layer" {
  for cross_min_type in layer_sweep_test_cross_types() {
    let creator = new_test_graph_creator()
    let layers = creator.make_layers(3)
    let left_node = creator.add_node_to_layer(layers[0])
    let middle_nodes = creator.add_nodes_to_layer(3, layers[1])
    let right_nodes = creator.add_nodes_to_layer(2, layers[2])

    creator.east_west_edge_from_to_nodes(middle_nodes[0], right_nodes[0])
    creator.east_west_edge_from_to_nodes(middle_nodes[1], right_nodes[0])
    creator.east_west_edge_from_to_nodes(middle_nodes[2], right_nodes[1])
    creator.east_west_edge_from_to_nodes(middle_nodes[2], right_nodes[1])
    creator.east_west_edge_from_to_nodes(left_node, middle_nodes[0])
    creator.east_west_edge_from_to_nodes(left_node, middle_nodes[0])
    creator.east_west_edge_from_to_nodes(left_node, middle_nodes[1])
    creator.east_west_edge_from_to_nodes(left_node, middle_nodes[1])

    creator.set_fixed_order_constraint(right_nodes[1])
    creator.set_fixed_order_constraint(right_nodes[0])
    creator.set_fixed_order_constraint(left_node)
    creator.set_up_ids()

    let expected_bottom_middle_port_order = creator.copy_ports_in_index_order(
      middle_nodes[2],
      [1, 0],
    )

    layer_sweep_test_run(creator, cross_min_type)

    let middle_layer = creator.get_graph().get_layers()[1]
    assert_true(
      layer_sweep_test_nodes_in_order(
        middle_nodes[0],
        middle_nodes[1],
        middle_layer,
      ),
    )
    assert_eq(
      layer_sweep_test_port_handles(middle_nodes[2].get_ports()),
      layer_sweep_test_port_handles(expected_bottom_middle_port_order),
    )
  }
}

///|
test "LayerSweep ignores removable fixed-order port crossings in score" {
  for cross_min_type in layer_sweep_test_cross_types() {
    let creator = new_test_graph_creator()
    let layers = creator.make_layers(3)
    let left_node = creator.add_node_to_layer(layers[0])
    let middle_nodes = creator.add_nodes_to_layer(3, layers[1])
    let right_nodes = creator.add_nodes_to_layer(2, layers[2])

    creator.east_west_edge_from_to_nodes(middle_nodes[0], right_nodes[0])
    creator.east_west_edge_from_to_nodes(middle_nodes[1], right_nodes[0])
    creator.east_west_edge_from_to_nodes(middle_nodes[2], right_nodes[1])
    creator.east_west_edge_from_to_nodes(middle_nodes[2], right_nodes[1])
    creator.east_west_edge_from_to_nodes(left_node, middle_nodes[0])
    creator.east_west_edge_from_to_nodes(left_node, middle_nodes[1])

    creator.set_fixed_order_constraint(right_nodes[1])
    creator.set_fixed_order_constraint(right_nodes[0])
    creator.set_fixed_order_constraint(left_node)
    creator.set_up_ids()

    let expected_bottom_middle_port_order = creator.copy_ports_in_index_order(
      middle_nodes[2],
      [1, 0],
    )

    layer_sweep_test_run(creator, cross_min_type)

    let middle_layer = creator.get_graph().get_layers()[1]
    assert_true(
      layer_sweep_test_nodes_in_order(
        middle_nodes[0],
        middle_nodes[1],
        middle_layer,
      ),
    )
    assert_eq(
      layer_sweep_test_port_handles(middle_nodes[2].get_ports()),
      layer_sweep_test_port_handles(expected_bottom_middle_port_order),
    )
  }
}

///|
test "LayerSweep updates in-layer port order after beneficial switch" {
  let cross_types = layer_sweep_test_cross_types()
  for index in 0..<cross_types.length() {
    let cross_min_type = cross_types[index]
    let creator = new_test_graph_creator()
    let left_nodes = creator.add_nodes_to_layer(
      2,
      creator.make_layer(creator.get_graph()),
    )
    let middle_nodes = creator.add_nodes_to_layer(
      2,
      creator.make_layer(creator.get_graph()),
    )

    creator.east_west_edge_from_to_nodes(left_nodes[0], middle_nodes[1])
    creator.add_in_layer_edge_nodes(
      middle_nodes[1],
      middle_nodes[0],
      layer_sweep_test_west(),
    )
    creator.east_west_edge_from_to_nodes(left_nodes[1], middle_nodes[0])
    creator.set_up_ids()

    let expected_middle_node_order = creator.copy_of_switch_order_of_nodes_in_layer(
      0, 1, 1,
    )
    let expected_middle_top_node_ports = creator.copy_ports_in_index_order(
      middle_nodes[0],
      [1, 0],
    )

    layer_sweep_test_run(creator, cross_min_type)

    if index == 0 {
      assert_eq(
        layer_sweep_test_node_handles(
          creator.get_graph().get_layers()[1].get_nodes(),
        ),
        layer_sweep_test_node_handles(expected_middle_node_order),
      )
      assert_eq(
        layer_sweep_test_port_handles(middle_nodes[0].get_ports()),
        layer_sweep_test_port_handles(expected_middle_top_node_ports),
      )
    }
  }
}

///|
test "LayerSweep resolves crossing when one nested side has no external dummies" {
  for cross_min_type in layer_sweep_test_cross_types() {
    let creator = new_test_graph_creator()
    let root = creator.get_graph()
    let left_outer_node = creator.add_node_to_layer(creator.make_layer(root))
    let right_outer_node = creator.add_node_to_layer(creator.make_layer(root))
    let left_outer_ports = creator.add_ports_on_side(
      2,
      left_outer_node,
      layer_sweep_test_east(),
    )
    let right_outer_ports = creator.add_ports_on_side(
      2,
      right_outer_node,
      layer_sweep_test_west(),
    )
    creator.add_edge_between_ports(left_outer_ports[0], right_outer_ports[0])
    creator.add_edge_between_ports(left_outer_ports[1], right_outer_ports[1])

    ignore(
      layer_sweep_test_make_nested_two_node_graph_with_eastern_ports(
        creator, left_outer_node, left_outer_ports,
      ),
    )
    let right_inner_graph = creator.nested_graph(right_outer_node)
    ignore(creator.add_nodes_to_layer(2, creator.make_layer(right_inner_graph)))

    let expected_port_order_right = creator.get_list_copy_in_index_order(
      right_outer_ports,
      [1, 0],
    )

    layer_sweep_test_run(creator, cross_min_type)

    assert_eq(
      layer_sweep_test_port_handles(right_outer_node.get_ports()),
      layer_sweep_test_port_handles(expected_port_order_right),
    )
  }
}

///|
test "LayerSweep resolves crossing between compound and non-compound node" {
  for cross_min_type in layer_sweep_test_cross_types() {
    let creator = new_test_graph_creator()
    let root = creator.get_graph()
    let left_outer_node = creator.add_node_to_layer(creator.make_layer(root))
    let right_nodes = creator.add_nodes_to_layer(2, creator.make_layer(root))
    let left_outer_ports = creator.add_ports_on_side(
      2,
      left_outer_node,
      layer_sweep_test_east(),
    )
    creator.east_west_edge_from_to_port_node(
      left_outer_ports[0],
      right_nodes[1],
    )
    creator.east_west_edge_from_to_port_node(
      left_outer_ports[1],
      right_nodes[0],
    )
    ignore(
      layer_sweep_test_make_nested_two_node_graph_with_eastern_ports(
        creator, left_outer_node, left_outer_ports,
      ),
    )

    let expected_order_right = creator.copy_of_switch_order_of_nodes_in_layer(
      0, 1, 1,
    )

    layer_sweep_test_run(creator, cross_min_type)

    assert_eq(
      layer_sweep_test_node_handles(root.get_layers()[1].get_nodes()),
      layer_sweep_test_node_handles(expected_order_right),
    )
  }
}

///|
test "LayerSweep takes forward result when backward sweep worsens" {
  for cross_min_type in layer_sweep_test_cross_types() {
    let creator = new_test_graph_creator()
    let layers = creator.make_layers(3)
    let left_node = creator.add_node_to_layer(layers[0])
    creator.set_fixed_order_constraint(left_node)
    let middle_nodes = creator.add_nodes_to_layer(2, layers[1])
    let right_node = creator.add_node_to_layer(layers[2])
    creator.set_fixed_order_constraint(right_node)

    creator.east_west_edge_from_to_nodes(left_node, middle_nodes[1])
    creator.east_west_edge_from_to_nodes(left_node, middle_nodes[1])
    creator.east_west_edge_from_to_nodes(left_node, middle_nodes[0])
    creator.east_west_edge_from_to_nodes(left_node, middle_nodes[0])
    creator.east_west_edge_from_to_nodes(middle_nodes[1], right_node)
    creator.east_west_edge_from_to_nodes(middle_nodes[0], right_node)

    let expected_middle_order = creator.copy_of_switch_order_of_nodes_in_layer(
      0, 1, 1,
    )

    layer_sweep_test_run(creator, cross_min_type)

    assert_eq(
      layer_sweep_test_node_handles(creator.copy_of_nodes_in_layer(1)),
      layer_sweep_test_node_handles(expected_middle_order),
    )
  }
}

///|
test "LayerSweep resolves simple hierarchical cross with sweepiness enabled" {
  let cross_types = layer_sweep_test_cross_types()
  for cross_min_type in cross_types {
    let creator = new_test_graph_creator()
    let root = creator.get_graph()
    let left_outer_node = creator.add_node_to_layer(creator.make_layer(root))
    let right_outer_node = creator.add_node_to_layer(creator.make_layer(root))
    let left_outer_ports = creator.add_ports_on_side(
      2,
      left_outer_node,
      layer_sweep_test_east(),
    )
    let right_outer_ports = creator.add_ports_on_side(
      2,
      right_outer_node,
      layer_sweep_test_west(),
    )
    creator.add_edge_between_ports(left_outer_ports[0], right_outer_ports[0])
    creator.add_edge_between_ports(left_outer_ports[1], right_outer_ports[1])

    ignore(
      layer_sweep_test_make_nested_two_node_graph_with_eastern_ports(
        creator, left_outer_node, left_outer_ports,
      ),
    )
    let right_inner_graph = layer_sweep_test_make_nested_two_node_graph_with_western_ports(
      creator, right_outer_node, right_outer_ports,
    )

    let expected_external_dummy_order_right = creator.switch_order_of_nodes_in_layer(
      0,
      1,
      right_inner_graph.get_layers()[0],
    )
    let expected_normal_node_order_right = creator.switch_order_of_nodes_in_layer(
      0,
      1,
      right_inner_graph.get_layers()[1],
    )
    let expected_port_order_right = creator.get_list_copy_in_index_order(
      right_outer_ports,
      [1, 0],
    )

    layer_sweep_test_set_on_all_graphs(
      root, layered_options_crossing_minimization_hierarchical_sweepiness, 0.1,
    )
    layer_sweep_test_run(creator, cross_min_type)

    assert_eq(
      layer_sweep_test_node_handles(
        right_inner_graph.get_layers()[0].get_nodes(),
      ),
      layer_sweep_test_node_handles(expected_external_dummy_order_right),
    )
    assert_eq(
      layer_sweep_test_port_handles(right_outer_node.get_ports()),
      layer_sweep_test_port_handles(expected_port_order_right),
    )
    assert_eq(
      layer_sweep_test_node_handles(
        right_inner_graph.get_layers()[1].get_nodes(),
      ),
      layer_sweep_test_node_handles(expected_normal_node_order_right),
    )
  }
}

///|
test "LayerSweep resolves crossing in first-level compound node" {
  for cross_min_type in layer_sweep_test_cross_types() {
    let creator = new_test_graph_creator()
    let root = creator.get_graph()

    let left_outer_node = creator.add_node_to_layer(creator.make_layer(root))
    let right_nodes = creator.add_nodes_to_layer(2, creator.make_layer(root))
    let left_outer_ports = creator.add_ports_on_side(
      2,
      left_outer_node,
      layer_sweep_test_east(),
    )
    creator.east_west_edge_from_to_port_node(
      left_outer_ports[0],
      right_nodes[0],
    )
    creator.east_west_edge_from_to_port_node(
      left_outer_ports[1],
      right_nodes[1],
    )

    let left_inner_graph = creator.nested_graph(left_outer_node)
    let left_inner_nodes_left = creator.add_nodes_to_layer(
      2,
      creator.make_layer(left_inner_graph),
    )
    let left_inner_nodes_right = creator.add_nodes_to_layer(
      2,
      creator.make_layer(left_inner_graph),
    )
    let left_inner_dummy_nodes = creator.add_external_port_dummies_to_layer(
      creator.make_layer(left_inner_graph),
      left_outer_ports,
    )
    creator.east_west_edge_from_to_nodes(
      left_inner_nodes_right[0],
      left_inner_dummy_nodes[0],
    )
    creator.east_west_edge_from_to_nodes(
      left_inner_nodes_right[1],
      left_inner_dummy_nodes[1],
    )
    creator.east_west_edge_from_to_nodes(
      left_inner_nodes_left[0],
      left_inner_nodes_right[1],
    )
    creator.east_west_edge_from_to_nodes(
      left_inner_nodes_left[1],
      left_inner_nodes_right[0],
    )

    let expected_order_right = creator.copy_of_switch_order_of_nodes_in_layer(
      0, 1, 1,
    )
    layer_sweep_test_run(creator, cross_min_type)

    assert_eq(
      layer_sweep_test_node_handles(root.get_layers()[1].get_nodes()),
      layer_sweep_test_node_handles(expected_order_right),
    )
  }
}

///|
test "LayerSweep improves non-nested graph on backward sweep" {
  for cross_min_type in layer_sweep_test_cross_types() {
    let creator = new_test_graph_creator()
    let left_layer = creator.make_layer(creator.get_graph())
    let right_layer = creator.make_layer(creator.get_graph())
    let left_top_node = creator.add_node_to_layer(left_layer)
    let left_bottom_node = creator.add_node_to_layer(left_layer)
    let right_node = creator.add_node_to_layer(right_layer)

    creator.set_fixed_order_constraint(right_node)
    creator.east_west_edge_from_to_nodes(left_top_node, right_node)
    creator.east_west_edge_from_to_nodes(left_bottom_node, right_node)

    let expected_order_layer_one = creator.copy_of_switch_order_of_nodes_in_layer(
      0, 1, 0,
    )

    creator.get_random().set_next_boolean(false)
    layer_sweep_test_run(creator, cross_min_type)

    assert_eq(
      layer_sweep_test_node_handles(creator.copy_of_nodes_in_layer(0)),
      layer_sweep_test_node_handles(expected_order_layer_one),
    )
  }
}

///|
test "LayerSweep does not randomly reorder first layer on backward sweep" {
  for cross_min_type in layer_sweep_test_cross_types() {
    let creator = new_test_graph_creator()
    let layers = creator.make_layers(2)
    let left_nodes = creator.add_nodes_to_layer(2, layers[0])
    let right_nodes = creator.add_nodes_to_layer(3, layers[1])

    creator.east_west_edge_from_to_nodes(left_nodes[0], right_nodes[0])
    creator.east_west_edge_from_to_nodes(left_nodes[0], right_nodes[2])
    creator.east_west_edge_from_to_nodes(left_nodes[1], right_nodes[1])

    let expected_order_layer_two = creator.copy_of_switch_order_of_nodes_in_layer(
      1, 2, 1,
    )
    let expected_order_layer_one = creator.copy_of_nodes_in_layer(0)

    layer_sweep_test_run(creator, cross_min_type)

    assert_eq(
      layer_sweep_test_node_handles(creator.copy_of_nodes_in_layer(1)),
      layer_sweep_test_node_handles(expected_order_layer_two),
    )
    assert_eq(
      layer_sweep_test_node_handles(creator.copy_of_nodes_in_layer(0)),
      layer_sweep_test_node_handles(expected_order_layer_one),
    )
  }
}

///|
test "LayerSweep sorts wrongly seeded external dummies and resolves crossing" {
  let cross_types = layer_sweep_test_cross_types()
  for cross_min_type in cross_types {
    let creator = new_test_graph_creator()
    let left_outer_node = creator.add_node_to_layer(
      creator.make_layer(creator.get_graph()),
    )
    let right_outer_node = creator.add_node_to_layer(
      creator.make_layer(creator.get_graph()),
    )
    let left_outer_ports = creator.add_ports_on_side(
      2,
      left_outer_node,
      layer_sweep_test_east(),
    )
    let right_outer_ports = creator.add_ports_on_side(
      2,
      right_outer_node,
      layer_sweep_test_west(),
    )
    creator.add_edge_between_ports(left_outer_ports[0], right_outer_ports[0])
    creator.add_edge_between_ports(left_outer_ports[1], right_outer_ports[1])

    ignore(
      layer_sweep_test_make_nested_two_node_graph_with_eastern_ports(
        creator, left_outer_node, left_outer_ports,
      ),
    )

    let right_inner_graph = creator.nested_graph(right_outer_node)
    let right_inner_dummy_nodes = creator.add_external_port_dummies_to_layer(
      creator.make_layer(right_inner_graph),
      layer_sweep_test_reverse_ports(right_outer_ports),
    )
    let right_inner_nodes = creator.add_nodes_to_layer(
      2,
      creator.make_layer(right_inner_graph),
    )
    creator.east_west_edge_from_to_nodes(
      right_inner_dummy_nodes[1],
      right_inner_nodes[0],
    )
    creator.east_west_edge_from_to_nodes(
      right_inner_dummy_nodes[0],
      right_inner_nodes[1],
    )

    let expected_normal_node_order_right = creator.switch_order_of_nodes_in_layer(
      0,
      1,
      right_inner_graph.get_layers()[1],
    )
    let expected_order_of_ports_right = creator.get_list_copy_in_index_order(
      right_outer_ports,
      [1, 0],
    )

    layer_sweep_test_run(creator, cross_min_type)

    assert_eq(
      layer_sweep_test_node_handles(
        right_inner_graph.get_layers()[0].get_nodes(),
      ),
      layer_sweep_test_node_handles(right_inner_dummy_nodes),
    )
    assert_eq(
      layer_sweep_test_port_handles(right_outer_node.get_ports()),
      layer_sweep_test_port_handles(expected_order_of_ports_right),
    )
    assert_eq(
      layer_sweep_test_node_handles(
        right_inner_graph.get_layers()[1].get_nodes(),
      ),
      layer_sweep_test_node_handles(expected_normal_node_order_right),
    )
  }
}

///|
test "LayerSweep resolves crossing between normal and hierarchical edge" {
  for cross_min_type in layer_sweep_test_cross_types() {
    let creator = new_test_graph_creator()
    let layers = creator.make_layers(2)
    let left_outer_node = creator.add_node_to_layer(layers[0])
    let right_nodes = creator.add_nodes_to_layer(2, layers[1])
    creator.east_west_edge_from_to_nodes(left_outer_node, right_nodes[1])

    let inner_layers = creator.make_layers_in_graph(
      2,
      creator.nested_graph(left_outer_node),
    )
    let inner_normal_node = creator.add_node_to_layer(inner_layers[0])
    let hierarch_port = creator.add_port_on_side(
      left_outer_node,
      layer_sweep_test_east(),
    )
    let inner_dummy_node = creator.add_external_port_dummy_node_to_layer(
      inner_layers[1],
      hierarch_port,
    )
    creator.east_west_edge_from_to_nodes(inner_normal_node, inner_dummy_node)

    let right_top_port = creator.add_port_on_side(
      right_nodes[0],
      layer_sweep_test_west(),
    )
    creator.add_edge_between_ports(hierarch_port, right_top_port)

    let expected_order = creator.copy_of_switch_order_of_nodes_in_layer(0, 1, 1)
    layer_sweep_test_run(creator, cross_min_type)

    assert_eq(
      layer_sweep_test_node_handles(
        creator.get_graph().get_layers()[1].get_nodes(),
      ),
      layer_sweep_test_node_handles(expected_order),
    )
  }
}

///|
test "LayerSweep resolves crossing with unconnected extra hierarchical port" {
  for cross_min_type in layer_sweep_test_cross_types() {
    let creator = new_test_graph_creator()
    let layers = creator.make_layers(2)
    let left_outer_node = creator.add_node_to_layer(layers[0])
    let right_nodes = creator.add_nodes_to_layer(2, layers[1])
    creator.east_west_edge_from_to_nodes(left_outer_node, right_nodes[1])

    let inner_layers = creator.make_layers_in_graph(
      2,
      creator.nested_graph(left_outer_node),
    )
    let inner_normal_node = creator.add_node_to_layer(inner_layers[0])
    let hierarch_port = creator.add_port_on_side(
      left_outer_node,
      layer_sweep_test_east(),
    )
    let inner_dummy_node = creator.add_external_port_dummy_node_to_layer(
      inner_layers[1],
      hierarch_port,
    )
    creator.east_west_edge_from_to_nodes(inner_normal_node, inner_dummy_node)
    ignore(creator.add_port_on_side(left_outer_node, layer_sweep_test_east()))

    let right_top_port = creator.add_port_on_side(
      right_nodes[0],
      layer_sweep_test_west(),
    )
    creator.add_edge_between_ports(hierarch_port, right_top_port)

    let expected_order = creator.copy_of_switch_order_of_nodes_in_layer(0, 1, 1)
    layer_sweep_test_run(creator, cross_min_type)

    assert_eq(
      layer_sweep_test_node_handles(
        creator.get_graph().get_layers()[1].get_nodes(),
      ),
      layer_sweep_test_node_handles(expected_order),
    )
  }
}

///|
test "LayerSweep keeps order under hyperedge counter fixed-port case" {
  for cross_min_type in layer_sweep_test_cross_types() {
    let creator = new_test_graph_creator()
    let left_node = creator.add_node_to_layer(
      creator.make_layer(creator.get_graph()),
    )
    let right_nodes = creator.add_nodes_to_layer(
      2,
      creator.make_layer(creator.get_graph()),
    )
    let lower_right_port = creator.add_port_on_side(
      right_nodes[1],
      layer_sweep_test_west(),
    )
    let lower_right_port2 = creator.add_port_on_side(
      right_nodes[1],
      layer_sweep_test_west(),
    )
    let left_ports = creator.add_ports_on_side(
      3,
      left_node,
      layer_sweep_test_east(),
    )

    creator.add_edge_between_ports(left_ports[0], lower_right_port2)
    creator.add_edge_between_ports(left_ports[0], lower_right_port2)
    creator.east_west_edge_from_to_port_node(left_ports[1], right_nodes[0])
    creator.add_edge_between_ports(left_ports[2], lower_right_port)
    creator.set_port_order_fixed(left_node)

    let expected_order_right = right_nodes
    creator.get_random().set_next_boolean(false)
    layer_sweep_test_run(creator, cross_min_type)

    assert_eq(
      layer_sweep_test_node_handles(
        creator.get_graph().get_layers()[1].get_nodes(),
      ),
      layer_sweep_test_node_handles(expected_order_right),
    )
  }
}

///|
test "LayerSweep non-recursive fixed-order to hierarchical graph removes crossing" {
  for cross_min_type in layer_sweep_test_cross_types() {
    let creator = new_test_graph_creator()
    let root = creator.get_graph()

    let left_node = creator.add_node_to_layer(creator.make_layer(root))
    creator.set_fixed_order_constraint(left_node)
    let right_outer_node = creator.add_node_to_layer(creator.make_layer(root))
    creator.east_west_edge_from_to_nodes(left_node, right_outer_node)

    let right_outer_port = creator.add_port_on_side(
      right_outer_node,
      layer_sweep_test_west(),
    )
    let left_lower_port = creator.add_port_on_side(
      left_node,
      layer_sweep_test_east(),
    )
    creator.add_edge_between_ports(left_lower_port, right_outer_port)

    let right_inner_graph = creator.nested_graph(right_outer_node)
    let right_inner_dummy_node = creator.add_external_port_dummy_node_to_layer(
      creator.make_layer(right_inner_graph),
      right_outer_port,
    )
    let right_inner_node = creator.add_node_to_layer(
      creator.make_layer(right_inner_graph),
    )
    creator.east_west_edge_from_to_nodes(
      right_inner_dummy_node, right_inner_node,
    )

    let expected_port_order_right = creator.get_list_copy_in_index_order(
      right_outer_node.get_ports(),
      [1, 0],
    )

    layer_sweep_test_set_on_all_graphs(
      root, layered_options_crossing_minimization_hierarchical_sweepiness, 1.0,
    )
    layer_sweep_test_run(creator, cross_min_type)

    assert_eq(
      layer_sweep_test_port_handles(
        root.get_layers()[1].get_nodes()[0].get_ports(),
      ),
      layer_sweep_test_port_handles(expected_port_order_right),
    )
  }
}

///|
test "LayerSweep transports switched port order through hierarchy west-east" {
  for cross_min_type in layer_sweep_test_cross_types() {
    let creator = new_test_graph_creator()
    let root = creator.get_graph()

    let left_node = creator.add_node_to_layer(creator.make_layer(root))
    creator.set_fixed_order_constraint(left_node)
    let middle_outer_node = creator.add_node_to_layer(creator.make_layer(root))
    let right_nodes = creator.add_nodes_to_layer(2, creator.make_layer(root))

    let middle_outer_right_ports = creator.add_ports_on_side(
      2,
      middle_outer_node,
      layer_sweep_test_east(),
    )
    creator.east_west_edge_from_to_port_node(
      middle_outer_right_ports[0],
      right_nodes[0],
    )
    creator.east_west_edge_from_to_port_node(
      middle_outer_right_ports[1],
      right_nodes[1],
    )

    let left_ports = creator.add_ports_on_side(
      2,
      left_node,
      layer_sweep_test_east(),
    )
    let middle_outer_left_ports = creator.add_ports_on_side(
      2,
      middle_outer_node,
      layer_sweep_test_west(),
    )
    creator.add_edge_between_ports(left_ports[0], middle_outer_left_ports[0])
    creator.add_edge_between_ports(left_ports[1], middle_outer_left_ports[1])

    let inner_graph = creator.nested_graph(middle_outer_node)
    let left_inner_dummy_nodes = creator.add_external_port_dummies_to_layer(
      creator.make_layer(inner_graph),
      middle_outer_left_ports,
    )
    let inner_nodes = creator.add_nodes_to_layer(
      2,
      creator.make_layer(inner_graph),
    )
    let right_inner_dummy_nodes = creator.add_external_port_dummies_to_layer(
      creator.make_layer(inner_graph),
      middle_outer_right_ports,
    )

    creator.east_west_edge_from_to_nodes(
      inner_nodes[0],
      right_inner_dummy_nodes[0],
    )
    creator.east_west_edge_from_to_nodes(
      inner_nodes[1],
      right_inner_dummy_nodes[1],
    )
    creator.east_west_edge_from_to_nodes(
      left_inner_dummy_nodes[0],
      inner_nodes[0],
    )
    creator.east_west_edge_from_to_nodes(
      left_inner_dummy_nodes[1],
      inner_nodes[1],
    )

    let expected_ports = creator.copy_ports_in_index_order(middle_outer_node, [
      1, 0, 3, 2,
    ])

    layer_sweep_test_run(creator, cross_min_type)

    assert_eq(
      layer_sweep_test_port_handles(
        root.get_layers()[1].get_nodes()[0].get_ports(),
      ),
      layer_sweep_test_port_handles(expected_ports),
    )
  }
}

///|
test "LayerSweep transports switched port order through hierarchy east-west" {
  let cross_min_type = layer_sweep_test_cross_types()[0]
  let creator = new_test_graph_creator()
  let root = creator.get_graph()

  let left_nodes = creator.add_nodes_to_layer(2, creator.make_layer(root))
  let middle_outer_node = creator.add_node_to_layer(creator.make_layer(root))
  let right_node = creator.add_node_to_layer(creator.make_layer(root))
  creator.set_fixed_order_constraint(right_node)

  let left_ports_right_node = creator.add_ports_on_side(
    2,
    right_node,
    layer_sweep_test_west(),
  )
  let middle_outer_right_ports = creator.add_ports_on_side(
    2,
    middle_outer_node,
    layer_sweep_test_east(),
  )
  creator.add_edge_between_ports(
    middle_outer_right_ports[0],
    left_ports_right_node[0],
  )
  creator.add_edge_between_ports(
    middle_outer_right_ports[1],
    left_ports_right_node[1],
  )

  let middle_outer_left_ports = creator.add_ports_on_side(
    2,
    middle_outer_node,
    layer_sweep_test_west(),
  )
  creator.east_west_edge_from_to_node_port(
    left_nodes[0],
    middle_outer_left_ports[1],
  )
  creator.east_west_edge_from_to_node_port(
    left_nodes[1],
    middle_outer_left_ports[0],
  )

  let inner_graph = creator.nested_graph(middle_outer_node)
  let left_inner_dummy_nodes = creator.add_external_port_dummies_to_layer(
    creator.make_layer(inner_graph),
    middle_outer_left_ports,
  )
  let inner_nodes = creator.add_nodes_to_layer(
    2,
    creator.make_layer(inner_graph),
  )
  let right_inner_dummy_nodes = creator.add_external_port_dummies_to_layer(
    creator.make_layer(inner_graph),
    middle_outer_right_ports,
  )

  creator.east_west_edge_from_to_nodes(
    inner_nodes[0],
    right_inner_dummy_nodes[0],
  )
  creator.east_west_edge_from_to_nodes(
    inner_nodes[1],
    right_inner_dummy_nodes[1],
  )
  creator.east_west_edge_from_to_nodes(
    left_inner_dummy_nodes[0],
    inner_nodes[0],
  )
  creator.east_west_edge_from_to_nodes(
    left_inner_dummy_nodes[1],
    inner_nodes[1],
  )

  let expected_port_order_middle_node = creator.copy_ports_in_index_order(
    middle_outer_node,
    [1, 0, 3, 2],
  )

  creator.get_random().set_next_boolean(false)
  layer_sweep_test_run(creator, cross_min_type)

  assert_eq(
    layer_sweep_test_port_handles(
      root.get_layers()[1].get_nodes()[0].get_ports(),
    ),
    layer_sweep_test_port_handles(expected_port_order_middle_node),
  )
}

///|
test "LayerSweep recursive backward-sweep candidate still corrects inner port order" {
  let cross_types = layer_sweep_test_cross_types()
  for index in 0..<cross_types.length() {
    let cross_min_type = cross_types[index]
    let creator = new_test_graph_creator()

    let left_outer_node = creator.add_node_to_layer(
      creator.make_layer(creator.get_graph()),
    )
    let right_outer_node = creator.add_node_to_layer(
      creator.make_layer(creator.get_graph()),
    )
    creator.east_west_edge_from_to_nodes(left_outer_node, right_outer_node)

    let left_inner_graph = creator.nested_graph(left_outer_node)
    let layers = creator.make_layers_in_graph(3, left_inner_graph)
    let left_node = creator.add_node_to_layer(layers[0])
    let middle_nodes = creator.add_nodes_to_layer(3, layers[1])
    let right_nodes = creator.add_nodes_to_layer(2, layers[2])

    creator.east_west_edge_from_to_nodes(middle_nodes[0], right_nodes[0])
    creator.east_west_edge_from_to_nodes(middle_nodes[1], right_nodes[0])
    creator.east_west_edge_from_to_nodes(middle_nodes[2], right_nodes[1])
    creator.east_west_edge_from_to_nodes(middle_nodes[2], right_nodes[1])
    creator.east_west_edge_from_to_nodes(left_node, middle_nodes[0])
    creator.east_west_edge_from_to_nodes(left_node, middle_nodes[0])
    creator.east_west_edge_from_to_nodes(left_node, middle_nodes[1])
    creator.east_west_edge_from_to_nodes(left_node, middle_nodes[1])

    creator.set_fixed_order_constraint(right_nodes[1])
    creator.set_fixed_order_constraint(right_nodes[0])
    creator.set_fixed_order_constraint(left_node)

    let right_inner_graph = creator.nested_graph(right_outer_node)
    let right_graph_left_nodes = creator.add_nodes_to_layer(
      2,
      creator.make_layer(right_inner_graph),
    )
    let right_graph_right_nodes = creator.add_nodes_to_layer(
      2,
      creator.make_layer(right_inner_graph),
    )
    creator.east_west_edge_from_to_nodes(
      right_graph_left_nodes[0],
      right_graph_right_nodes[1],
    )
    creator.east_west_edge_from_to_nodes(
      right_graph_left_nodes[1],
      right_graph_right_nodes[0],
    )
    creator.set_up_ids()

    let expected_port_order_bottom_middle_node = creator.copy_ports_in_index_order(
      middle_nodes[2],
      [1, 0],
    )

    layer_sweep_test_run(creator, cross_min_type)

    if index == 0 {
      let middle_layer = left_inner_graph.get_layers()[1]
      assert_true(
        layer_sweep_test_nodes_in_order(
          middle_nodes[0],
          middle_nodes[1],
          middle_layer,
        ),
      )
      assert_eq(
        layer_sweep_test_port_handles(middle_nodes[2].get_ports()),
        layer_sweep_test_port_handles(expected_port_order_bottom_middle_node),
      )
    }
  }
}

///|
test "LayerSweep recursive first-level cross sorts parent ports accordingly" {
  let cross_types = layer_sweep_test_cross_types()
  for index in 0..<cross_types.length() {
    let cross_min_type = cross_types[index]
    let creator = new_test_graph_creator()
    let root = creator.get_graph()

    let left_outer_node = creator.add_node_to_layer(creator.make_layer(root))
    let right_nodes = creator.add_nodes_to_layer(2, creator.make_layer(root))
    let left_outer_ports = creator.add_ports_on_side(
      2,
      left_outer_node,
      layer_sweep_test_east(),
    )
    creator.east_west_edge_from_to_port_node(
      left_outer_ports[0],
      right_nodes[0],
    )
    creator.east_west_edge_from_to_port_node(
      left_outer_ports[1],
      right_nodes[1],
    )

    let left_inner_graph = creator.nested_graph(left_outer_node)
    let left_inner_nodes_left = creator.add_nodes_to_layer(
      9,
      creator.make_layer(left_inner_graph),
    )
    let left_inner_nodes_right = creator.add_nodes_to_layer(
      9,
      creator.make_layer(left_inner_graph),
    )
    let left_inner_dummy_nodes = creator.add_external_port_dummies_to_layer(
      creator.make_layer(left_inner_graph),
      left_outer_ports,
    )
    creator.east_west_edge_from_to_nodes(
      left_inner_nodes_right[0],
      left_inner_dummy_nodes[0],
    )
    creator.east_west_edge_from_to_nodes(
      left_inner_nodes_right[1],
      left_inner_dummy_nodes[1],
    )
    creator.east_west_edge_from_to_nodes(
      left_inner_nodes_left[0],
      left_inner_nodes_right[1],
    )
    creator.east_west_edge_from_to_nodes(
      left_inner_nodes_left[1],
      left_inner_nodes_right[0],
    )
    for i in 2..<left_inner_nodes_left.length() {
      creator.east_west_edge_from_to_nodes(
        left_inner_nodes_left[i],
        left_inner_nodes_right[i],
      )
    }

    let expected_order_right = creator.copy_of_switch_order_of_nodes_in_layer(
      0, 1, 1,
    )
    let expected_port_order_left = creator.copy_ports_in_index_order(
      left_outer_node,
      [1, 0],
    )

    layer_sweep_test_run(creator, cross_min_type)

    if index == 0 {
      assert_eq(
        layer_sweep_test_port_handles(left_outer_node.get_ports()),
        layer_sweep_test_port_handles(expected_port_order_left),
      )
      assert_eq(
        layer_sweep_test_node_handles(root.get_layers()[1].get_nodes()),
        layer_sweep_test_node_handles(expected_order_right),
      )
    }
  }
}

///|
test "LayerSweep handles hierarchical cross with north-south edge" {
  let cross_types = layer_sweep_test_cross_types()
  for index in 0..<cross_types.length() {
    let cross_min_type = cross_types[index]
    let creator = new_test_graph_creator()
    let root = creator.get_graph()

    let left_nodes = creator.add_nodes_to_layer(3, creator.make_layer(root))
    let left_outer_node = left_nodes[1]
    let right_nodes = creator.add_nodes_to_layer(3, creator.make_layer(root))
    let right_outer_node = right_nodes[1]

    creator.add_north_south_edge(
      layer_sweep_test_north(),
      right_outer_node,
      right_nodes[0],
      left_nodes[0],
      true,
    )

    let left_outer_ports = creator.add_ports_on_side(
      2,
      left_outer_node,
      layer_sweep_test_east(),
    )
    let right_outer_ports = creator.add_ports_on_side(
      2,
      right_outer_node,
      layer_sweep_test_west(),
    )
    creator.add_edge_between_ports(left_outer_ports[0], right_outer_ports[0])
    creator.add_edge_between_ports(left_outer_ports[1], right_outer_ports[1])

    ignore(
      layer_sweep_test_make_nested_two_node_graph_with_eastern_ports(
        creator, left_outer_node, left_outer_ports,
      ),
    )

    creator.add_north_south_edge(
      layer_sweep_test_south(),
      left_outer_node,
      left_nodes[2],
      right_nodes[2],
      false,
    )

    let right_inner_graph = layer_sweep_test_make_nested_two_node_graph_with_western_ports(
      creator, right_outer_node, right_outer_ports,
    )
    let expected_external_dummy_order_right = creator.switch_order_of_nodes_in_layer(
      0,
      1,
      right_inner_graph.get_layers()[0],
    )
    let expected_normal_node_order_right = creator.switch_order_of_nodes_in_layer(
      0,
      1,
      right_inner_graph.get_layers()[1],
    )
    let expected_order_of_ports_right = [
      right_outer_node.get_ports()[0],
      right_outer_ports[1],
      right_outer_ports[0],
    ]

    layer_sweep_test_run(creator, cross_min_type)

    assert_eq(
      layer_sweep_test_node_handles(
        right_inner_graph.get_layers()[0].get_nodes(),
      ),
      layer_sweep_test_node_handles(expected_external_dummy_order_right),
    )
    assert_eq(
      layer_sweep_test_port_handles(right_outer_node.get_ports()),
      layer_sweep_test_port_handles(expected_order_of_ports_right),
    )
    assert_eq(
      layer_sweep_test_node_handles(
        right_inner_graph.get_layers()[1].get_nodes(),
      ),
      layer_sweep_test_node_handles(expected_normal_node_order_right),
    )
  }
}

///|
test "LayerSweep all-recursive first-level cross removes crossing" {
  let cross_types = layer_sweep_test_cross_types()
  for index in 0..<cross_types.length() {
    let cross_min_type = cross_types[index]
    let creator = new_test_graph_creator()
    let root = creator.get_graph()

    let left_outer_node = creator.add_node_to_layer(creator.make_layer(root))
    let right_nodes = creator.add_nodes_to_layer(2, creator.make_layer(root))
    let left_outer_ports = creator.add_ports_on_side(
      2,
      left_outer_node,
      layer_sweep_test_east(),
    )
    creator.east_west_edge_from_to_port_node(
      left_outer_ports[0],
      right_nodes[0],
    )
    creator.east_west_edge_from_to_port_node(
      left_outer_ports[1],
      right_nodes[1],
    )

    let left_inner_graph = creator.nested_graph(left_outer_node)
    let left_inner_nodes_left = creator.add_nodes_to_layer(
      2,
      creator.make_layer(left_inner_graph),
    )
    let left_inner_nodes_right = creator.add_nodes_to_layer(
      2,
      creator.make_layer(left_inner_graph),
    )
    let left_inner_dummy_nodes = creator.add_external_port_dummies_to_layer(
      creator.make_layer(left_inner_graph),
      left_outer_ports,
    )
    creator.east_west_edge_from_to_nodes(
      left_inner_nodes_right[0],
      left_inner_dummy_nodes[0],
    )
    creator.east_west_edge_from_to_nodes(
      left_inner_nodes_right[1],
      left_inner_dummy_nodes[1],
    )
    creator.east_west_edge_from_to_nodes(
      left_inner_nodes_left[0],
      left_inner_nodes_right[1],
    )
    creator.east_west_edge_from_to_nodes(
      left_inner_nodes_left[1],
      left_inner_nodes_right[0],
    )
    root.set_property_double(
      layered_options_crossing_minimization_hierarchical_sweepiness, -1.0,
    )

    let expected_order_right = creator.copy_of_switch_order_of_nodes_in_layer(
      0, 1, 1,
    )
    let expected_inner_order_right = creator.get_list_copy_in_index_order(
      left_inner_nodes_right,
      [1, 0],
    )

    layer_sweep_test_run(creator, cross_min_type)

    if index == 0 {
      assert_eq(
        layer_sweep_test_node_handles(
          left_inner_graph.get_layers()[1].get_nodes(),
        ),
        layer_sweep_test_node_handles(expected_inner_order_right),
      )
      assert_eq(
        layer_sweep_test_node_handles(root.get_layers()[1].get_nodes()),
        layer_sweep_test_node_handles(expected_order_right),
      )
    }
  }
}

///|
test "LayerSweep handles in-layer crossings in left-most layer" {
  for cross_min_type in layer_sweep_test_cross_types() {
    let creator = new_test_graph_creator()
    let root = creator.get_graph()

    let nodes = creator.add_nodes_to_layer(4, creator.make_layer(root))
    let right_node = creator.add_node_to_layer(creator.make_layer(root))
    let right_outer_ports = creator.add_ports_on_side(
      2,
      right_node,
      layer_sweep_test_west(),
    )
    ignore(
      layer_sweep_test_make_nested_two_node_graph_with_western_ports(
        creator, right_node, right_outer_ports,
      ),
    )
    creator.east_west_edge_from_to_node_port(nodes[1], right_outer_ports[1])
    creator.east_west_edge_from_to_node_port(nodes[2], right_outer_ports[0])
    creator.add_in_layer_edge_nodes(nodes[0], nodes[2], layer_sweep_test_west())
    let port_one = creator.add_port_on_side(nodes[1], layer_sweep_test_west())
    let port_two = creator.add_port_on_side(nodes[3], layer_sweep_test_west())
    creator.add_edge_between_ports(port_one, port_two)
    creator.add_edge_between_ports(port_one, port_two)
    creator.set_fixed_order_constraint(right_node)

    let actual_order = root.get_layers()[0].get_nodes()
    let expected_order = creator.get_list_copy_in_index_order(actual_order, [
      1, 0, 2, 3,
    ])

    layer_sweep_test_run(creator, cross_min_type)

    assert_eq(
      layer_sweep_test_node_handles(actual_order),
      layer_sweep_test_node_handles(expected_order),
    )
  }
}

///|
test "LayerSweep handles in-layer cross-hierarchy crossings in left-most layer" {
  for cross_min_type in layer_sweep_test_cross_types() {
    let creator = new_test_graph_creator()
    let root = creator.get_graph()

    let nodes = creator.add_nodes_to_layer(5, creator.make_layer(root))
    ignore(creator.add_ports_on_side(2, nodes[0], layer_sweep_test_west()))
    ignore(creator.add_node_to_layer(creator.make_layer(root)))
    let top_node_ports = creator.add_ports_on_side(
      2,
      nodes[0],
      layer_sweep_test_west(),
    )
    let second_node_ports = creator.add_ports_on_side(
      3,
      nodes[1],
      layer_sweep_test_west(),
    )
    creator.add_edge_between_ports(top_node_ports[0], second_node_ports[2])
    creator.add_edge_between_ports(top_node_ports[1], second_node_ports[1])

    let outer_ports = creator.add_ports_on_side(
      2,
      nodes[2],
      layer_sweep_test_west(),
    )
    let inner = layer_sweep_test_make_nested_two_node_graph_with_western_ports(
      creator,
      nodes[2],
      outer_ports,
    )

    let fifth_node_ports = creator.add_ports_on_side(
      3,
      nodes[3],
      layer_sweep_test_west(),
    )
    let sixth_node_ports = creator.add_ports_on_side(
      2,
      nodes[4],
      layer_sweep_test_west(),
    )
    creator.add_edge_between_ports(fifth_node_ports[0], sixth_node_ports[1])
    creator.add_edge_between_ports(fifth_node_ports[1], sixth_node_ports[0])
    creator.add_edge_between_ports(outer_ports[0], fifth_node_ports[2])

    let actual_port_order = nodes[2].get_ports()
    let expected_port_order = creator.get_list_copy_in_index_order(
      actual_port_order,
      [1, 0],
    )
    let actual_node_order = root.get_layers()[0].get_nodes()
    let expected_node_order = actual_node_order.copy()
    let actual_inner_node_order = inner.get_layers()[1].get_nodes()
    let expected_inner_node_order = creator.get_list_copy_in_index_order(
      actual_inner_node_order,
      [1, 0],
    )

    root.set_property_double(
      layered_options_crossing_minimization_hierarchical_sweepiness, 1.0,
    )
    layer_sweep_test_run(creator, cross_min_type)

    assert_eq(
      layer_sweep_test_node_handles(actual_node_order),
      layer_sweep_test_node_handles(expected_node_order),
    )
    assert_eq(
      layer_sweep_test_port_handles(actual_port_order),
      layer_sweep_test_port_handles(expected_port_order),
    )
    assert_eq(
      layer_sweep_test_node_handles(actual_inner_node_order),
      layer_sweep_test_node_handles(expected_inner_node_order),
    )
  }
}

///|
test "LayerSweep marks needsHierarchical for simple hierarchical cross" {
  for cross_min_type in layer_sweep_test_cross_types() {
    let creator = new_test_graph_creator()
    let root = creator.get_graph()
    let left_outer_node = creator.add_node_to_layer(creator.make_layer(root))
    let right_outer_node = creator.add_node_to_layer(creator.make_layer(root))
    let left_outer_ports = creator.add_ports_on_side(
      2,
      left_outer_node,
      layer_sweep_test_east(),
    )
    let right_outer_ports = creator.add_ports_on_side(
      2,
      right_outer_node,
      layer_sweep_test_west(),
    )
    creator.add_edge_between_ports(left_outer_ports[0], right_outer_ports[1])
    creator.add_edge_between_ports(left_outer_ports[1], right_outer_ports[0])
    ignore(
      layer_sweep_test_make_nested_two_node_graph_with_eastern_ports(
        creator, left_outer_node, left_outer_ports,
      ),
    )
    ignore(
      layer_sweep_test_make_nested_two_node_graph_with_western_ports(
        creator, right_outer_node, right_outer_ports,
      ),
    )

    root.set_property_double(
      layered_options_crossing_minimization_hierarchical_sweepiness, 0.1,
    )

    let cross_min = layer_sweep_test_run_and_get_cross_min(
      creator, cross_min_type,
    )
    layer_sweep_test_assert_nested_graphs_not_marked_dont_sweep(
      cross_min.get_graph_data(),
    )
  }
}

///|
test "LayerSweep marks fixed-order transfer graphs for hierarchical sweep" {
  for cross_min_type in layer_sweep_test_cross_types() {
    let creator = new_test_graph_creator()
    let root = creator.get_graph()
    let left_outer_node = creator.add_node_to_layer(creator.make_layer(root))
    let middle_nodes = creator.add_nodes_to_layer(2, creator.make_layer(root))
    creator.set_fixed_order_constraint(middle_nodes[0])
    creator.set_fixed_order_constraint(middle_nodes[1])
    let right_outer_node = creator.add_node_to_layer(creator.make_layer(root))
    let left_outer_ports = creator.add_ports_on_side(
      2,
      left_outer_node,
      layer_sweep_test_east(),
    )
    let right_outer_ports = creator.add_ports_on_side(
      2,
      right_outer_node,
      layer_sweep_test_west(),
    )
    creator.east_west_edge_from_to_port_node(
      left_outer_ports[0],
      middle_nodes[0],
    )
    creator.east_west_edge_from_to_port_node(
      left_outer_ports[1],
      middle_nodes[1],
    )
    creator.east_west_edge_from_to_node_port(
      middle_nodes[0],
      right_outer_ports[0],
    )
    creator.east_west_edge_from_to_node_port(
      middle_nodes[1],
      right_outer_ports[1],
    )
    ignore(
      layer_sweep_test_make_nested_two_node_graph_with_eastern_ports(
        creator, left_outer_node, left_outer_ports,
      ),
    )
    ignore(
      layer_sweep_test_make_nested_two_node_graph_with_western_ports(
        creator, right_outer_node, right_outer_ports,
      ),
    )

    let cross_min = layer_sweep_test_run_and_get_cross_min(
      creator, cross_min_type,
    )
    layer_sweep_test_assert_nested_graphs_not_marked_dont_sweep(
      cross_min.get_graph_data(),
    )
  }
}

///|
test "LayerSweep marks hierarchical transfer graphs for hierarchical sweep" {
  for cross_min_type in layer_sweep_test_cross_types() {
    let creator = new_test_graph_creator()
    let root = creator.get_graph()
    let left_outer_node = creator.add_node_to_layer(creator.make_layer(root))
    let middle_nodes = creator.add_nodes_to_layer(2, creator.make_layer(root))
    ignore(
      creator.add_node_to_layer(
        creator.make_layer(creator.nested_graph(middle_nodes[0])),
      ),
    )
    ignore(
      creator.add_node_to_layer(
        creator.make_layer(creator.nested_graph(middle_nodes[1])),
      ),
    )
    let right_outer_node = creator.add_node_to_layer(creator.make_layer(root))
    let left_outer_ports = creator.add_ports_on_side(
      2,
      left_outer_node,
      layer_sweep_test_east(),
    )
    let right_outer_ports = creator.add_ports_on_side(
      2,
      right_outer_node,
      layer_sweep_test_west(),
    )
    creator.east_west_edge_from_to_port_node(
      left_outer_ports[0],
      middle_nodes[0],
    )
    creator.east_west_edge_from_to_port_node(
      left_outer_ports[1],
      middle_nodes[1],
    )
    creator.east_west_edge_from_to_node_port(
      middle_nodes[0],
      right_outer_ports[0],
    )
    creator.east_west_edge_from_to_node_port(
      middle_nodes[1],
      right_outer_ports[1],
    )
    ignore(
      layer_sweep_test_make_nested_two_node_graph_with_eastern_ports(
        creator, left_outer_node, left_outer_ports,
      ),
    )
    ignore(
      layer_sweep_test_make_nested_two_node_graph_with_western_ports(
        creator, right_outer_node, right_outer_ports,
      ),
    )

    let cross_min = layer_sweep_test_run_and_get_cross_min(
      creator, cross_min_type,
    )
    layer_sweep_test_set_on_all_graphs(
      root, layered_options_crossing_minimization_hierarchical_sweepiness, -1.0,
    )

    let left_nested_graph = match left_outer_node.get_nested_graph() {
      Some(graph) => graph
      None => abort("left outer node has no nested graph")
    }
    let right_nested_graph = match right_outer_node.get_nested_graph() {
      Some(graph) => graph
      None => abort("right outer node has no nested graph")
    }
    let graph_data = cross_min.get_graph_data()
    assert_eq(graph_data[left_nested_graph.get_id()].dont_sweep_into(), false)
    assert_eq(graph_data[right_nested_graph.get_id()].dont_sweep_into(), false)
  }
}

///|
test "LayerSweep marks fixed-order parent on right for hierarchical sweep" {
  for cross_min_type in layer_sweep_test_cross_types() {
    let creator = new_test_graph_creator()
    let root = creator.get_graph()
    let left_outer_node = creator.add_node_to_layer(creator.make_layer(root))
    let right_outer_node = creator.add_node_to_layer(creator.make_layer(root))
    creator.set_fixed_order_constraint(right_outer_node)
    let left_outer_ports = creator.add_ports_on_side(
      2,
      left_outer_node,
      layer_sweep_test_east(),
    )
    let right_outer_ports = creator.add_ports_on_side(
      2,
      right_outer_node,
      layer_sweep_test_west(),
    )
    creator.add_edge_between_ports(left_outer_ports[0], right_outer_ports[1])
    creator.add_edge_between_ports(left_outer_ports[1], right_outer_ports[0])
    ignore(
      layer_sweep_test_make_nested_two_node_graph_with_eastern_ports(
        creator, left_outer_node, left_outer_ports,
      ),
    )

    let cross_min = layer_sweep_test_run_and_get_cross_min(
      creator, cross_min_type,
    )
    layer_sweep_test_assert_nested_graphs_not_marked_dont_sweep(
      cross_min.get_graph_data(),
    )
  }
}

///|
test "LayerSweep marks fixed-order parent on left for hierarchical sweep" {
  for cross_min_type in layer_sweep_test_cross_types() {
    let creator = new_test_graph_creator()
    let root = creator.get_graph()
    let left_outer_node = creator.add_node_to_layer(creator.make_layer(root))
    let right_outer_node = creator.add_node_to_layer(creator.make_layer(root))
    creator.set_fixed_order_constraint(left_outer_node)
    let left_outer_ports = creator.add_ports_on_side(
      2,
      left_outer_node,
      layer_sweep_test_east(),
    )
    let right_outer_ports = creator.add_ports_on_side(
      2,
      right_outer_node,
      layer_sweep_test_west(),
    )
    creator.add_edge_between_ports(left_outer_ports[0], right_outer_ports[1])
    creator.add_edge_between_ports(left_outer_ports[1], right_outer_ports[0])
    ignore(
      layer_sweep_test_make_nested_two_node_graph_with_western_ports(
        creator, right_outer_node, right_outer_ports,
      ),
    )

    let cross_min = layer_sweep_test_run_and_get_cross_min(
      creator, cross_min_type,
    )
    layer_sweep_test_assert_nested_graphs_not_marked_dont_sweep(
      cross_min.get_graph_data(),
    )
  }
}

///|
test "LayerSweep keeps single hierarch-edge cross as no cross-hierarchy case" {
  for cross_min_type in layer_sweep_test_cross_types() {
    let creator = new_test_graph_creator()
    let root = creator.get_graph()
    let left_node = creator.add_node_to_layer(creator.make_layer(root))
    let right_outer_node = creator.add_node_to_layer(creator.make_layer(root))
    let right_outer_ports = creator.add_ports_on_side(
      2,
      right_outer_node,
      layer_sweep_test_west(),
    )
    creator.east_west_edge_from_to_node_port(left_node, right_outer_ports[1])
    layer_sweep_test_set_on_all_graphs(
      root, layered_options_crossing_minimization_hierarchical_sweepiness, 0.1,
    )
    ignore(
      layer_sweep_test_make_nested_two_node_graph_with_western_ports(
        creator, right_outer_node, right_outer_ports,
      ),
    )

    let cross_min = layer_sweep_test_run_and_get_cross_min(
      creator, cross_min_type,
    )
    layer_sweep_test_assert_nested_graphs_not_marked_dont_sweep(
      cross_min.get_graph_data(),
    )
  }
}

///|
test "LayerSweep avoids cross-hierarchy when random paths dominate (EW)" {
  let cross_types = layer_sweep_test_cross_types()
  for index in 0..<cross_types.length() {
    let cross_min_type = cross_types[index]
    let creator = new_test_graph_creator()
    let root = creator.get_graph()

    let left_outer_node = creator.add_node_to_layer(creator.make_layer(root))
    let left_outer_ports = creator.add_ports_on_side(
      2,
      left_outer_node,
      layer_sweep_test_east(),
    )
    ignore(
      layer_sweep_test_make_nested_two_node_graph_with_eastern_ports(
        creator, left_outer_node, left_outer_ports,
      ),
    )

    let middle_outer_node = creator.add_node_to_layer(creator.make_layer(root))
    let right_node = creator.add_node_to_layer(creator.make_layer(root))
    let right_outer_ports = creator.add_ports_on_side(
      1,
      middle_outer_node,
      layer_sweep_test_east(),
    )
    let middle_node_left_outer_ports = creator.add_ports_on_side(
      2,
      middle_outer_node,
      layer_sweep_test_west(),
    )
    creator.add_edge_between_ports(
      left_outer_ports[0],
      middle_node_left_outer_ports[1],
    )
    creator.add_edge_between_ports(
      left_outer_ports[1],
      middle_node_left_outer_ports[0],
    )
    creator.east_west_edge_from_to_port_node(right_outer_ports[0], right_node)

    let nested_graph = creator.nested_graph(middle_outer_node)
    let left_dummies = creator.add_external_port_dummies_to_layer(
      creator.make_layer(nested_graph),
      middle_node_left_outer_ports,
    )
    let left_inner_nodes = creator.add_nodes_to_layer(
      4,
      creator.make_layer(nested_graph),
    )
    let right_inner_nodes = creator.add_nodes_to_layer(
      2,
      creator.make_layer(nested_graph),
    )
    let right_dummies = creator.add_external_port_dummies_to_layer(
      creator.make_layer(nested_graph),
      right_outer_ports,
    )
    creator.east_west_edge_from_to_nodes(left_dummies[0], left_inner_nodes[3])
    creator.east_west_edge_from_to_nodes(
      left_inner_nodes[0],
      right_inner_nodes[0],
    )
    creator.east_west_edge_from_to_nodes(
      left_inner_nodes[1],
      right_inner_nodes[0],
    )
    creator.east_west_edge_from_to_nodes(
      left_inner_nodes[1],
      right_inner_nodes[1],
    )
    creator.east_west_edge_from_to_nodes(
      left_inner_nodes[2],
      right_inner_nodes[0],
    )
    creator.east_west_edge_from_to_nodes(
      left_inner_nodes[3],
      right_inner_nodes[1],
    )
    creator.east_west_edge_from_to_nodes(right_inner_nodes[1], right_dummies[0])

    layer_sweep_test_set_on_all_graphs(
      nested_graph, layered_options_crossing_minimization_hierarchical_sweepiness,
      0.0,
    )
    let cross_min = layer_sweep_test_run_and_get_cross_min(
      creator, cross_min_type,
    )
    let graph_data = cross_min.get_graph_data()
    if index == 0 {
      assert_eq(graph_data[nested_graph.get_id()].dont_sweep_into(), true)
    }
  }
}

///|
test "LayerSweep avoids cross-hierarchy when random paths dominate (with NS)" {
  let cross_types = layer_sweep_test_cross_types()
  for index in 0..<cross_types.length() {
    let cross_min_type = cross_types[index]
    let creator = new_test_graph_creator()
    let root = creator.get_graph()

    let left_outer_node = creator.add_node_to_layer(creator.make_layer(root))
    let left_outer_ports = creator.add_ports_on_side(
      2,
      left_outer_node,
      layer_sweep_test_east(),
    )
    ignore(
      layer_sweep_test_make_nested_two_node_graph_with_eastern_ports(
        creator, left_outer_node, left_outer_ports,
      ),
    )
    let middle_outer_node = creator.add_node_to_layer(creator.make_layer(root))
    let right_node = creator.add_node_to_layer(creator.make_layer(root))
    let right_outer_ports = creator.add_ports_on_side(
      1,
      middle_outer_node,
      layer_sweep_test_east(),
    )
    let middle_node_left_outer_ports = creator.add_ports_on_side(
      2,
      middle_outer_node,
      layer_sweep_test_west(),
    )
    creator.add_edge_between_ports(
      left_outer_ports[0],
      middle_node_left_outer_ports[1],
    )
    creator.add_edge_between_ports(
      left_outer_ports[1],
      middle_node_left_outer_ports[0],
    )
    creator.east_west_edge_from_to_port_node(right_outer_ports[0], right_node)

    let nested_graph = creator.nested_graph(middle_outer_node)
    let left_dummies = creator.add_external_port_dummies_to_layer(
      creator.make_layer(nested_graph),
      middle_node_left_outer_ports,
    )
    let left_inner_nodes = creator.add_nodes_to_layer(
      4,
      creator.make_layer(nested_graph),
    )
    let right_inner_nodes = creator.add_nodes_to_layer(
      3,
      creator.make_layer(nested_graph),
    )
    let right_dummies = creator.add_external_port_dummies_to_layer(
      creator.make_layer(nested_graph),
      right_outer_ports,
    )
    creator.east_west_edge_from_to_nodes(left_dummies[0], left_inner_nodes[3])
    creator.add_north_south_edge(
      layer_sweep_test_north(),
      right_inner_nodes[1],
      right_inner_nodes[0],
      left_inner_nodes[0],
      true,
    )
    creator.east_west_edge_from_to_nodes(
      left_inner_nodes[1],
      right_inner_nodes[1],
    )
    creator.east_west_edge_from_to_nodes(
      left_inner_nodes[1],
      right_inner_nodes[2],
    )
    creator.east_west_edge_from_to_nodes(
      left_inner_nodes[2],
      right_inner_nodes[1],
    )
    creator.east_west_edge_from_to_nodes(
      left_inner_nodes[3],
      right_inner_nodes[2],
    )
    creator.east_west_edge_from_to_nodes(right_inner_nodes[1], right_dummies[0])

    let cross_min = layer_sweep_test_run_and_get_cross_min(
      creator, cross_min_type,
    )
    let graph_data = cross_min.get_graph_data()
    if index == 0 {
      assert_eq(graph_data[nested_graph.get_id()].dont_sweep_into(), true)
    }
  }
}
