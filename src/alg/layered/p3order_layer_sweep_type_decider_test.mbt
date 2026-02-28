///|
fn layer_sweep_type_decider_test_pop_graph(graphs : Array[LGraph]) -> LGraph {
  match graphs.pop() {
    Some(graph) => graph
    None => abort("graph queue is empty")
  }
}

///|
fn layer_sweep_type_decider_test_to_node_array(
  graph : LGraph,
) -> Array[Array[LNode]] {
  let node_order = []
  for layer in graph.get_layers() {
    node_order.push(layer.get_nodes())
  }
  node_order
}

///|
fn layer_sweep_type_decider_test_set_on_all_graphs(
  root : LGraph,
  property : @graph.IProperty[Double],
  value : Double,
) -> Unit {
  let graphs = [root]
  while !graphs.is_empty() {
    let graph = layer_sweep_type_decider_test_pop_graph(graphs)
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
fn layer_sweep_type_decider_test_make_graph_info(
  graph : LGraph,
  parent_graph_data? : GraphInfoHolder? = None,
) -> GraphInfoHolder {
  new_graph_info_holder(
    layer_sweep_type_decider_test_to_node_array(graph),
    parent=graph.get_parent_node(),
    parent_graph_data~,
    l_graph=Some(graph),
  )
}

///|
fn layer_sweep_type_decider_test_north() -> @core.PortSide {
  @core.port_side_values()[1]
}

///|
fn layer_sweep_type_decider_test_east() -> @core.PortSide {
  @core.port_side_values()[2]
}

///|
fn layer_sweep_type_decider_test_south() -> @core.PortSide {
  @core.port_side_values()[3]
}

///|
fn layer_sweep_type_decider_test_west() -> @core.PortSide {
  @core.port_side_values()[4]
}

///|
test "LayerSweepTypeDecider north_south_ports_change_decision" {
  let creator = new_test_graph_creator()

  let layers = creator.make_layers(3)
  let left_outer = creator.add_node_to_layer(layers[0])
  let middle_outer = creator.add_node_to_layer(layers[1])
  let right_outer = creator.add_node_to_layer(layers[2])
  let left_port_middle_node = creator.add_port_on_side(
    middle_outer,
    layer_sweep_type_decider_test_west(),
  )
  let right_port_middle_node = creator.add_port_on_side(
    middle_outer,
    layer_sweep_type_decider_test_east(),
  )
  creator.east_west_edge_from_to_nodes(middle_outer, right_outer)
  creator.east_west_edge_from_to_port_node(right_port_middle_node, right_outer)
  creator.east_west_edge_from_to_node_port(left_outer, left_port_middle_node)
  creator.east_west_edge_from_to_nodes(left_outer, middle_outer)

  let nested_graph = creator.nested_graph(middle_outer)
  let inner_layers = creator.make_layers_in_graph(5, nested_graph)
  let left_dummy = creator.add_external_port_dummy_node_to_layer(
    inner_layers[0],
    left_port_middle_node,
  )
  let first_layer = creator.add_nodes_to_layer(3, inner_layers[1])
  let second_layer = creator.add_nodes_to_layer(3, inner_layers[2])
  let third_layer = creator.add_nodes_to_layer(2, inner_layers[3])
  let right_dummy = creator.add_external_port_dummy_node_to_layer(
    inner_layers[4],
    right_port_middle_node,
  )
  creator.east_west_edge_from_to_nodes(left_dummy, first_layer[2])
  creator.east_west_edge_from_to_nodes(first_layer[2], second_layer[2])
  creator.east_west_edge_from_to_nodes(second_layer[2], third_layer[1])
  creator.east_west_edge_from_to_nodes(third_layer[1], right_dummy)

  creator.add_north_south_edge(
    layer_sweep_type_decider_test_north(),
    first_layer[1],
    first_layer[0],
    second_layer[0],
    false,
  )
  creator.add_north_south_edge(
    layer_sweep_type_decider_test_south(),
    second_layer[0],
    second_layer[1],
    third_layer[0],
    false,
  )

  let graph = creator.get_graph()
  graph.set_id(0)
  nested_graph.set_id(1)
  layer_sweep_type_decider_test_set_on_all_graphs(
    graph, layered_options_crossing_minimization_hierarchical_sweepiness, 0.1,
  )

  let root_data = layer_sweep_type_decider_test_make_graph_info(graph)
  let nested_data = layer_sweep_type_decider_test_make_graph_info(
    nested_graph,
    parent_graph_data=Some(root_data),
  )
  let decider = new_layer_sweep_type_decider(nested_data)
  i_initializable_init(
    [decider.as_initializable()],
    nested_data.current_node_order(),
  )

  assert_true(decider.use_bottom_up())
}

///|
test "LayerSweepTypeDecider all_hierarchical_but_minus_one_still_returns_bottom_up" {
  let creator = new_test_graph_creator()

  let left_node = creator.add_node_to_layer(
    creator.make_layer(creator.get_graph()),
  )
  let middle_node = creator.add_node_to_layer(
    creator.make_layer(creator.get_graph()),
  )
  let right_node = creator.add_node_to_layer(
    creator.make_layer(creator.get_graph()),
  )
  let middle_port_right = creator.add_ports_on_side(
    2,
    middle_node,
    layer_sweep_type_decider_test_east(),
  )
  let middle_port_left = creator.add_ports_on_side(
    2,
    middle_node,
    layer_sweep_type_decider_test_west(),
  )
  creator.east_west_edge_from_to_node_port(left_node, middle_port_left[1])
  creator.east_west_edge_from_to_node_port(left_node, middle_port_left[0])
  creator.east_west_edge_from_to_port_node(middle_port_right[0], right_node)
  creator.east_west_edge_from_to_port_node(middle_port_right[1], right_node)

  let inner_graph = creator.nested_graph(middle_node)
  let layers = creator.make_layers_in_graph(3, inner_graph)
  let left_inner_dummy_nodes = creator.add_external_port_dummies_to_layer(
    layers[2],
    middle_port_right,
  )
  let node = creator.add_node_to_layer(layers[1])
  let right_inner_dummy_nodes = creator.add_external_port_dummies_to_layer(
    layers[0],
    middle_port_left,
  )
  creator.east_west_edge_from_to_nodes(left_inner_dummy_nodes[0], node)
  creator.east_west_edge_from_to_nodes(left_inner_dummy_nodes[1], node)
  creator.east_west_edge_from_to_nodes(node, right_inner_dummy_nodes[0])
  creator.east_west_edge_from_to_nodes(node, right_inner_dummy_nodes[1])

  let graph = creator.get_graph()
  graph.set_id(0)
  inner_graph.set_id(1)
  layer_sweep_type_decider_test_set_on_all_graphs(
    graph, layered_options_crossing_minimization_hierarchical_sweepiness, -1.0,
  )

  let root_data = layer_sweep_type_decider_test_make_graph_info(graph)
  let inner_data = layer_sweep_type_decider_test_make_graph_info(
    inner_graph,
    parent_graph_data=Some(root_data),
  )
  let decider = new_layer_sweep_type_decider(inner_data)
  i_initializable_init(
    [decider.as_initializable()],
    inner_data.current_node_order(),
  )

  assert_true(decider.use_bottom_up())
}

///|
test "LayerSweepTypeDecider port_with_no_edges_does_not_count" {
  let creator = new_test_graph_creator()

  let middle_node = creator.add_node_to_layer(
    creator.make_layer(creator.get_graph()),
  )
  let right_node = creator.add_node_to_layer(
    creator.make_layer(creator.get_graph()),
  )
  let middle_port_right = creator.add_ports_on_side(
    2,
    middle_node,
    layer_sweep_type_decider_test_east(),
  )
  creator.east_west_edge_from_to_port_node(middle_port_right[0], right_node)
  creator.east_west_edge_from_to_port_node(middle_port_right[1], right_node)

  let inner_graph = creator.nested_graph(middle_node)
  let layers = creator.make_layers_in_graph(2, inner_graph)
  let node = creator.add_node_to_layer(layers[0])
  let right_inner_dummy_nodes = creator.add_external_port_dummies_to_layer(
    layers[1],
    middle_port_right,
  )
  creator.east_west_edge_from_to_nodes(node, right_inner_dummy_nodes[0])
  creator.east_west_edge_from_to_nodes(node, right_inner_dummy_nodes[1])
  ignore(creator.add_port_on_side(node, layer_sweep_type_decider_test_west()))

  let graph = creator.get_graph()
  graph.set_id(0)
  inner_graph.set_id(1)
  layer_sweep_type_decider_test_set_on_all_graphs(
    graph, layered_options_crossing_minimization_hierarchical_sweepiness, -0.1,
  )

  let root_data = layer_sweep_type_decider_test_make_graph_info(graph)
  let inner_data = layer_sweep_type_decider_test_make_graph_info(
    inner_graph,
    parent_graph_data=Some(root_data),
  )
  let decider = new_layer_sweep_type_decider(inner_data)
  i_initializable_init(
    [decider.as_initializable()],
    inner_data.current_node_order(),
  )

  assert_true(decider.use_bottom_up())
}
