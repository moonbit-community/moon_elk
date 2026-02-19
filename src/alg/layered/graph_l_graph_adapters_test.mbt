///|
fn l_graph_adapters_test_new_graph_with_layer() -> (LGraph, Layer) {
  let graph = new_l_graph()
  let layer = new_layer(graph)
  graph.get_layers().push(layer)
  (graph, layer)
}

///|
fn l_graph_adapters_test_new_layer_node(
  graph : LGraph,
  layer : Layer,
  node_type : NodeType,
) -> LNode {
  let node = new_l_node(graph=Some(graph))
  node.set_type(node_type)
  node.set_layer(Some(layer))
  node
}

///|
fn l_graph_adapters_test_add_port(node : LNode, side : @core.PortSide) -> LPort {
  let port = new_l_port()
  port.set_side(side)
  port.set_node(Some(node))
  node.add_port(port)
  port
}

///|
fn l_graph_adapters_test_connect(source : LPort, target : LPort) -> LEdge {
  let edge = new_l_edge()
  edge.set_source(Some(source))
  edge.set_target(Some(target))
  edge
}

///|
fn l_graph_adapters_test_node_type_normal() -> NodeType {
  node_type_values()[0]
}

///|
fn l_graph_adapters_test_node_type_north_south_port() -> NodeType {
  node_type_values()[3]
}

///|
fn l_graph_adapters_test_port_side_north() -> @core.PortSide {
  @core.port_side_values()[1]
}

///|
fn l_graph_adapters_test_port_side_east() -> @core.PortSide {
  @core.port_side_values()[2]
}

///|
fn l_graph_adapters_test_port_side_west() -> @core.PortSide {
  @core.port_side_values()[4]
}

///|
fn l_graph_adapters_test_port_constraints_fixed_order() -> @core.PortConstraints {
  @core.port_constraints_values()[3]
}

///|
fn l_graph_adapters_test_node_type_name(node_type : NodeType) -> String {
  match node_type {
    NodeType::Normal => "NORMAL"
    NodeType::LongEdge => "LONG_EDGE"
    NodeType::ExternalPort => "EXTERNAL_PORT"
    NodeType::NorthSouthPort => "NORTH_SOUTH_PORT"
    NodeType::LabelNode => "LABEL"
    NodeType::BreakingPoint => "BREAKING_POINT"
    NodeType::Placeholder => "PLACEHOLDER"
    NodeType::NonshiftingPlaceholder => "NONSHIFTING_PLACEHOLDER"
  }
}

///|
test "l graph adapter includes transparent comment nodes and applies node filter" {
  let (graph, layer) = l_graph_adapters_test_new_graph_with_layer()

  let visible = l_graph_adapters_test_new_layer_node(
    graph,
    layer,
    l_graph_adapters_test_node_type_normal(),
  )
  let hidden = l_graph_adapters_test_new_layer_node(
    graph,
    layer,
    l_graph_adapters_test_node_type_normal(),
  )
  hidden.set_id(99)

  let top_comment = new_l_node(graph=Some(graph))
  let bottom_comment = new_l_node(graph=Some(graph))
  visible.set_property_l_node_array(internal_properties_top_comments, [
    top_comment,
  ])
  visible.set_property_l_node_array(internal_properties_bottom_comments, [
    bottom_comment,
  ])

  let adapter = adapt_l_graph_with_options(graph, false, true, node => {
    node.get_id() != 99
  })
  let nodes = adapter.get_nodes()

  assert_eq(nodes.length(), 3)
}

///|
test "l port adapter transparently exposes dummy edges and hides north south dummy edges" {
  let (graph, layer) = l_graph_adapters_test_new_graph_with_layer()

  let main_node = l_graph_adapters_test_new_layer_node(
    graph,
    layer,
    l_graph_adapters_test_node_type_normal(),
  )
  let source_node = l_graph_adapters_test_new_layer_node(
    graph,
    layer,
    l_graph_adapters_test_node_type_normal(),
  )
  let target_node = l_graph_adapters_test_new_layer_node(
    graph,
    layer,
    l_graph_adapters_test_node_type_normal(),
  )
  let dummy_node = l_graph_adapters_test_new_layer_node(
    graph,
    layer,
    l_graph_adapters_test_node_type_normal(),
  )

  let main_port = l_graph_adapters_test_add_port(
    main_node,
    l_graph_adapters_test_port_side_east(),
  )
  let source_port = l_graph_adapters_test_add_port(
    source_node,
    l_graph_adapters_test_port_side_west(),
  )
  let target_port = l_graph_adapters_test_add_port(
    target_node,
    l_graph_adapters_test_port_side_west(),
  )
  let dummy_port = l_graph_adapters_test_add_port(
    dummy_node,
    l_graph_adapters_test_port_side_west(),
  )

  ignore(l_graph_adapters_test_connect(source_port, main_port))
  ignore(l_graph_adapters_test_connect(main_port, target_port))

  let source_for_dummy = l_graph_adapters_test_add_port(
    source_node,
    l_graph_adapters_test_port_side_west(),
  )
  let target_for_dummy = l_graph_adapters_test_add_port(
    target_node,
    l_graph_adapters_test_port_side_west(),
  )
  ignore(l_graph_adapters_test_connect(source_for_dummy, dummy_port))
  ignore(l_graph_adapters_test_connect(dummy_port, target_for_dummy))

  main_port.set_property_l_node(
    internal_properties_port_dummy,
    Some(dummy_node),
  )

  let main_adapter = new_l_port_adapter(main_port, true)
  assert_eq(main_adapter.get_incoming_edges().length(), 2)
  assert_eq(main_adapter.get_outgoing_edges().length(), 2)

  let north_south_node = l_graph_adapters_test_new_layer_node(
    graph,
    layer,
    l_graph_adapters_test_node_type_north_south_port(),
  )
  let north_south_port = l_graph_adapters_test_add_port(
    north_south_node,
    l_graph_adapters_test_port_side_north(),
  )
  assert_eq(
    l_graph_adapters_test_node_type_name(north_south_node.get_type()),
    "NORTH_SOUTH_PORT",
  )
  ignore(l_graph_adapters_test_connect(source_port, north_south_port))
  let north_south_adapter = new_l_port_adapter(north_south_port, true)
  assert_eq(north_south_adapter.get_incoming_edges().length(), 0)
}

///|
test "l node adapter sorts fixed-order ports with default comparator" {
  let (graph, layer) = l_graph_adapters_test_new_graph_with_layer()
  let node = l_graph_adapters_test_new_layer_node(
    graph,
    layer,
    l_graph_adapters_test_node_type_normal(),
  )
  node.set_property_string(
    @core.port_constraints,
    @core.port_constraints_to_string(
      l_graph_adapters_test_port_constraints_fixed_order(),
    ),
  )

  let port2 = l_graph_adapters_test_add_port(
    node,
    l_graph_adapters_test_port_side_east(),
  )
  port2.set_property_int(layered_options_port_index, 2)

  let port1 = l_graph_adapters_test_add_port(
    node,
    l_graph_adapters_test_port_side_east(),
  )
  port1.set_property_int(layered_options_port_index, 1)

  let adapter = adapt_l_node(node, false)
  adapter.sort_port_list()

  let sorted_ports = node.get_ports()
  assert_eq(sorted_ports.length(), 2)
  assert_eq(sorted_ports[0].get_property_int(layered_options_port_index), 1)
  assert_eq(sorted_ports[1].get_property_int(layered_options_port_index), 2)
}

///|
test "l graph adapters delegate property accessors to wrapped elements" {
  let (graph, layer) = l_graph_adapters_test_new_graph_with_layer()
  graph.set_property_bool(layered_options_feedback_edges, true)
  graph.set_property_string(@core.direction, "LEFT")
  let graph_adapter = adapt_l_graph(graph)
  assert_true(graph_adapter.has_property_bool(layered_options_feedback_edges))
  assert_true(graph_adapter.get_property_bool(layered_options_feedback_edges))
  assert_eq(graph_adapter.get_property_string(@core.direction), "LEFT")

  let node = l_graph_adapters_test_new_layer_node(
    graph,
    layer,
    l_graph_adapters_test_node_type_normal(),
  )
  node.set_property_int(layered_options_layering_layer_id, 7)
  node.set_property_bool(internal_properties_compound_node, true)
  let node_adapter = adapt_l_node(node, false)
  assert_true(node_adapter.has_property_int(layered_options_layering_layer_id))
  assert_eq(node_adapter.get_property_int(layered_options_layering_layer_id), 7)
  assert_true(node_adapter.get_property_bool(internal_properties_compound_node))

  let port = l_graph_adapters_test_add_port(
    node,
    l_graph_adapters_test_port_side_east(),
  )
  port.set_property_int(layered_options_port_index, 11)
  let port_adapter = new_l_port_adapter(port, false)
  assert_true(port_adapter.has_property_int(layered_options_port_index))
  assert_eq(port_adapter.get_property_int(layered_options_port_index), 11)

  let label = new_l_label_text("hello")
  label.set_property_string(@core.edge_labels_placement, "HEAD")
  let label_adapter = new_l_label_adapter(label)
  assert_true(label_adapter.has_property_string(@core.edge_labels_placement))
  assert_eq(label_adapter.get_property_string(@core.edge_labels_placement), "HEAD")
}

///|
test "l node adapter keeps parent graph adapter reference from creator" {
  let (graph, layer) = l_graph_adapters_test_new_graph_with_layer()
  let node = l_graph_adapters_test_new_layer_node(
    graph,
    layer,
    l_graph_adapters_test_node_type_normal(),
  )

  let graph_adapter = adapt_l_graph(graph)
  let nodes = graph_adapter.get_nodes()
  assert_eq(nodes.length(), 1)

  let parent_adapter = match nodes[0].get_graph() {
    Some(value) => value
    None => abort("Expected node adapter to keep parent graph adapter.")
  }
  parent_adapter.set_volatile_id(314)
  assert_eq(graph_adapter.get_volatile_id(), 314)

  let standalone_node_adapter = adapt_l_node(node, false)
  assert_true(standalone_node_adapter.get_graph() is None)
}
