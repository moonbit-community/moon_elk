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
test "LayerSweep handles empty and one-node graphs" {
  for cross_min_type in layer_sweep_test_cross_types() {
    let empty_creator = new_test_graph_creator()
    let empty_graph = empty_creator.get_empty_graph()
    let empty_cross_min = new_layer_sweep_crossing_minimizer(cross_min_type)
    empty_cross_min.process(
      empty_graph,
      progress_monitor=Some(new_basic_progress_monitor()),
    )

    let single_creator = new_test_graph_creator()
    let one_node_graph = single_creator.get_one_node_graph()
    let single_cross_min = new_layer_sweep_crossing_minimizer(cross_min_type)
    single_cross_min.process(
      one_node_graph,
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

    let expected_external_dummy_order_right_unchanged = right_inner_graph.get_layers()[0]
      .get_nodes()
      .copy()
    let expected_normal_node_order_right_unchanged = right_inner_graph.get_layers()[1]
      .get_nodes()
      .copy()
    let expected_port_order_right = creator.get_list_copy_in_index_order(
      right_outer_ports,
      [1, 0],
    )

    layer_sweep_test_set_on_all_graphs(
      root, layered_options_crossing_minimization_hierarchical_sweepiness, 0.1,
    )
    layer_sweep_test_run(creator, cross_min_type)

    let expected_external_dummy_order = expected_external_dummy_order_right_unchanged
    let expected_normal_node_order = expected_normal_node_order_right_unchanged
    assert_eq(
      layer_sweep_test_node_handles(
        right_inner_graph.get_layers()[0].get_nodes(),
      ),
      layer_sweep_test_node_handles(expected_external_dummy_order),
    )
    assert_eq(
      layer_sweep_test_port_handles(right_outer_node.get_ports()),
      layer_sweep_test_port_handles(expected_port_order_right),
    )
    assert_eq(
      layer_sweep_test_node_handles(
        right_inner_graph.get_layers()[1].get_nodes(),
      ),
      layer_sweep_test_node_handles(expected_normal_node_order),
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

    let expected_normal_node_order_right_unchanged = right_inner_graph.get_layers()[1]
      .get_nodes()
      .copy()
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
    let expected_normal_node_order = expected_normal_node_order_right_unchanged
    assert_eq(
      layer_sweep_test_node_handles(
        right_inner_graph.get_layers()[1].get_nodes(),
      ),
      layer_sweep_test_node_handles(expected_normal_node_order),
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
