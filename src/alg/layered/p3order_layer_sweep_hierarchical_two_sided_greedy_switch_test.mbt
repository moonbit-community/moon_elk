///|
fn layer_sweep_two_sided_node_handles(nodes : Array[LNode]) -> Array[Int] {
  let handles = []
  for node in nodes {
    handles.push(node.get_handle())
  }
  handles
}

///|
fn layer_sweep_two_sided_port_handles(ports : Array[LPort]) -> Array[Int] {
  let handles = []
  for port in ports {
    handles.push(port.get_handle())
  }
  handles
}

///|
fn layer_sweep_two_sided_pop_graph(graphs : Array[LGraph]) -> LGraph {
  match graphs.pop() {
    Some(graph) => graph
    None => abort("graph stack is empty")
  }
}

///|
fn layer_sweep_two_sided_east() -> @core.PortSide {
  @core.port_side_values()[2]
}

///|
fn layer_sweep_two_sided_west() -> @core.PortSide {
  @core.port_side_values()[4]
}

///|
fn layer_sweep_two_sided_set_on_all_graphs(
  root : LGraph,
  property : @graph.IProperty[Double],
  value : Double,
) -> Unit {
  let graphs = [root]
  while !graphs.is_empty() {
    let graph = layer_sweep_two_sided_pop_graph(graphs)
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
fn layer_sweep_two_sided_run(creator : TestGraphCreator) -> Unit {
  let cross_min = new_layer_sweep_crossing_minimizer(
    cross_min_type_constants()[2],
  )
  cross_min.process(
    creator.get_graph(),
    progress_monitor=Some(new_basic_progress_monitor()),
  )
}

///|
test "LayerSweep two-sided leaves crossing in first-level compound node" {
  let creator = new_test_graph_creator()

  let root = creator.get_graph()
  let left_outer_node = creator.add_node_to_layer(creator.make_layer(root))
  let right_nodes = creator.add_nodes_to_layer(2, creator.make_layer(root))
  let left_outer_ports = creator.add_ports_on_side(
    2,
    left_outer_node,
    layer_sweep_two_sided_east(),
  )
  creator.east_west_edge_from_to_port_node(left_outer_ports[0], right_nodes[0])
  creator.east_west_edge_from_to_port_node(left_outer_ports[1], right_nodes[1])

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

  layer_sweep_two_sided_set_on_all_graphs(
    root, layered_options_crossing_minimization_hierarchical_sweepiness, -1.0,
  )

  let expected_same_order = creator.copy_of_nodes_in_layer(1)
  layer_sweep_two_sided_run(creator)

  assert_eq(
    layer_sweep_two_sided_node_handles(root.get_layers()[1].get_nodes()),
    layer_sweep_two_sided_node_handles(expected_same_order),
  )
}

///|
test "LayerSweep two-sided removes crossing when corrected on forward sweep" {
  let creator = new_test_graph_creator()

  let node = creator.add_node_to_layer(creator.make_layer(creator.get_graph()))
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
  layer_sweep_two_sided_run(creator)

  assert_eq(
    layer_sweep_two_sided_port_handles(left_inner_node.get_ports()),
    layer_sweep_two_sided_port_handles(expected_left_port_order),
  )
  assert_eq(
    layer_sweep_two_sided_node_handles(right_inner_layer.get_nodes()),
    layer_sweep_two_sided_node_handles(expected_right_order),
  )
}

///|
test "LayerSweep two-sided removes crossing in single hierarchical node" {
  let creator = new_test_graph_creator()

  let node = creator.add_node_to_layer(creator.make_layer(creator.get_graph()))
  let inner_graph = creator.nested_graph(node)
  let inner_nodes_left = creator.add_nodes_to_layer(
    2,
    creator.make_layer(inner_graph),
  )
  let inner_nodes_right = creator.add_nodes_to_layer(
    2,
    creator.make_layer(inner_graph),
  )
  creator.east_west_edge_from_to_nodes(
    inner_nodes_left[0],
    inner_nodes_right[1],
  )
  creator.east_west_edge_from_to_nodes(
    inner_nodes_left[1],
    inner_nodes_right[0],
  )

  let expected_left_order = creator.switch_order_of_nodes_in_layer(
    0,
    1,
    inner_graph.get_layers()[0],
  )

  layer_sweep_two_sided_run(creator)

  assert_eq(
    layer_sweep_two_sided_node_handles(inner_graph.get_layers()[0].get_nodes()),
    layer_sweep_two_sided_node_handles(expected_left_order),
  )
}

///|
test "LayerSweep two-sided keeps dummy order when no improvement exists" {
  let creator = new_test_graph_creator()
  let root = creator.get_graph()

  let left_node = creator.add_node_to_layer(creator.make_layer(root))
  let right_node = creator.add_node_to_layer(creator.make_layer(root))
  let left_ports = creator.add_ports_on_side(
    2,
    left_node,
    layer_sweep_two_sided_east(),
  )
  creator.east_west_edge_from_to_port_node(left_ports[0], right_node)
  creator.east_west_edge_from_to_port_node(left_ports[1], right_node)
  creator.set_fixed_order_constraint(right_node)

  let inner_graph = creator.nested_graph(left_node)
  let inner_layers = creator.make_layers_in_graph(2, inner_graph)
  let inner_left_node = creator.add_node_to_layer(inner_layers[0])
  creator.set_fixed_order_constraint(inner_left_node)
  let dummies = creator.add_external_port_dummies_to_layer(
    inner_layers[1],
    left_ports,
  )
  creator.east_west_edge_from_to_nodes(inner_left_node, dummies[0])
  creator.east_west_edge_from_to_nodes(inner_left_node, dummies[1])

  let expected_dummy_order = inner_graph.get_layers()[1].get_nodes().copy()
  creator.get_random().set_next_boolean(false)
  layer_sweep_two_sided_run(creator)

  assert_eq(
    layer_sweep_two_sided_node_handles(inner_graph.get_layers()[1].get_nodes()),
    layer_sweep_two_sided_node_handles(expected_dummy_order),
  )
}

///|
test "LayerSweep two-sided prevents outside crossing from last-layer swap" {
  let creator = new_test_graph_creator()
  let root = creator.get_graph()

  let left_node = creator.add_node_to_layer(creator.make_layer(root))
  let right_node = creator.add_node_to_layer(creator.make_layer(root))
  let left_ports = creator.add_ports_on_side(
    2,
    left_node,
    layer_sweep_two_sided_east(),
  )
  creator.east_west_edge_from_to_port_node(left_ports[1], right_node)
  creator.east_west_edge_from_to_port_node(left_ports[0], right_node)
  creator.set_fixed_order_constraint(right_node)

  let inner_graph = creator.nested_graph(left_node)
  let inner_layers = creator.make_layers_in_graph(2, inner_graph)
  let inner_left_node = creator.add_node_to_layer(inner_layers[0])
  creator.set_fixed_order_constraint(inner_left_node)
  let dummies = creator.add_external_port_dummies_to_layer(
    inner_layers[1],
    left_ports,
  )
  creator.east_west_edge_from_to_nodes(inner_left_node, dummies[1])
  creator.east_west_edge_from_to_nodes(inner_left_node, dummies[0])

  let expected_dummy_order = inner_graph.get_layers()[1].get_nodes().copy()
  layer_sweep_two_sided_run(creator)

  assert_eq(
    layer_sweep_two_sided_node_handles(inner_graph.get_layers()[1].get_nodes()),
    layer_sweep_two_sided_node_handles(expected_dummy_order),
  )
}

///|
test "LayerSweep two-sided prevents outside crossing from first-layer swap" {
  let creator = new_test_graph_creator()
  let root = creator.get_graph()

  let left_node = creator.add_node_to_layer(creator.make_layer(root))
  let right_node = creator.add_node_to_layer(creator.make_layer(root))
  let right_ports = creator.add_ports_on_side(
    2,
    right_node,
    layer_sweep_two_sided_west(),
  )
  creator.east_west_edge_from_to_node_port(left_node, right_ports[1])
  creator.east_west_edge_from_to_node_port(left_node, right_ports[0])
  creator.set_fixed_order_constraint(left_node)

  let inner_graph = creator.nested_graph(right_node)
  let inner_layers = creator.make_layers_in_graph(2, inner_graph)
  let inner_right_node = creator.add_node_to_layer(inner_layers[1])
  creator.set_fixed_order_constraint(inner_right_node)
  let dummies = creator.add_external_port_dummies_to_layer(
    inner_layers[0],
    right_ports,
  )
  creator.east_west_edge_from_to_nodes(dummies[0], inner_right_node)
  creator.east_west_edge_from_to_nodes(dummies[1], inner_right_node)

  let expected_dummy_order = inner_graph.get_layers()[0].get_nodes().copy()
  creator.get_random().set_next_boolean(false)
  layer_sweep_two_sided_run(creator)

  assert_eq(
    layer_sweep_two_sided_node_handles(inner_graph.get_layers()[0].get_nodes()),
    layer_sweep_two_sided_node_handles(expected_dummy_order),
  )
}
