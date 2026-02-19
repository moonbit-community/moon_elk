///|
fn elk_graph_adapters_test_set_port_side(
  port : @graph.ElkPort,
  side_name : String,
) -> Unit {
  @graph.port_set_layout_option_string_by_id(
    port,
    port_side.get_id(),
    side_name,
  )
}

///|
fn elk_graph_adapters_test_set_label_side(
  label : @graph.ElkLabel,
  side_name : String,
) -> Unit {
  @graph.label_set_layout_option_string_by_id(label, "labelSide", side_name)
}

///|
test "elk graph adapter adapts and caches child nodes" {
  @graph.reset_graph_model_for_test()

  let root = @graph.create_graph()
  let child1 = @graph.create_node(Some(root))
  let child2 = @graph.create_node(Some(root))

  let graph_adapter = adapt(root)
  let nodes1 = graph_adapter.get_nodes()
  inspect(nodes1.length(), content="2")
  inspect(nodes1[0].get_node() == child1, content="true")
  inspect(nodes1[1].get_node() == child2, content="true")

  nodes1[0].set_volatile_id(23)
  let nodes2 = graph_adapter.get_nodes()
  inspect(nodes2[0].get_volatile_id(), content="23")
}

///|
test "adapt single node uses parent graph when present" {
  @graph.reset_graph_model_for_test()

  let root = @graph.create_graph()
  let child = @graph.create_node(Some(root))

  let root_adapter = adapt_single_node(root)
  let child_adapter = adapt_single_node(child)

  inspect(root_adapter.get_graph() is None, content="true")
  inspect(child_adapter.get_graph() is Some(_), content="true")
}

///|
test "node adapter exposes labels ports and incident edges" {
  @graph.reset_graph_model_for_test()

  let root = @graph.create_graph()
  let node1 = @graph.create_node(Some(root))
  let node2 = @graph.create_node(Some(root))
  let port1 = @graph.create_port(Some(node1))
  let port2 = @graph.create_port(Some(node2))

  let label = @graph.create_label(Some(@graph.make_node_label_parent(node1)))
  @graph.label_set_text(label, "n1")

  let in_edge = @graph.create_edge(Some(root))
  @graph.edge_add_source(in_edge, @graph.make_node_shape(node2))
  @graph.edge_add_target(in_edge, @graph.make_node_shape(node1))

  let port_edge = @graph.create_edge(Some(root))
  @graph.edge_add_source(port_edge, @graph.make_port_shape(port2))
  @graph.edge_add_target(port_edge, @graph.make_port_shape(port1))

  let out_edge = @graph.create_edge(Some(root))
  @graph.edge_add_source(out_edge, @graph.make_port_shape(port1))
  @graph.edge_add_target(out_edge, @graph.make_node_shape(node2))

  let adapter = adapt_single_node(node1)

  inspect(adapter.get_labels().length(), content="1")
  inspect(adapter.get_ports().length(), content="1")
  inspect(adapter.get_incoming_edges().length(), content="2")
  inspect(adapter.get_outgoing_edges().length(), content="1")
  inspect(adapter.is_compound_node(), content="false")

  @graph.node_set_bool_property(node1, inside_self_loops_activate, true)
  inspect(adapter.is_compound_node(), content="true")
}

///|
test "node adapter sort port list respects fixed order constraint" {
  @graph.reset_graph_model_for_test()

  let root = @graph.create_graph()
  let ordered = @graph.create_node(Some(root))
  @graph.node_set_string_property(ordered, port_constraints, "FIXED_ORDER")
  let ordered_port1 = @graph.create_port(Some(ordered))
  let ordered_port2 = @graph.create_port(Some(ordered))
  @graph.port_set_location(ordered_port1, 10.0, 0.0)
  @graph.port_set_location(ordered_port2, 2.0, 0.0)
  elk_graph_adapters_test_set_port_side(ordered_port1, "NORTH")
  elk_graph_adapters_test_set_port_side(ordered_port2, "NORTH")

  let ordered_adapter = adapt_single_node(ordered)
  ordered_adapter.sort_port_list()
  let ordered_ports = ordered_adapter.get_ports()
  inspect(ordered_ports[0].get_port() == ordered_port2, content="true")
  inspect(ordered_ports[1].get_port() == ordered_port1, content="true")

  let unordered = @graph.create_node(Some(root))
  let unordered_port1 = @graph.create_port(Some(unordered))
  let unordered_port2 = @graph.create_port(Some(unordered))
  @graph.port_set_location(unordered_port1, 10.0, 0.0)
  @graph.port_set_location(unordered_port2, 2.0, 0.0)
  elk_graph_adapters_test_set_port_side(unordered_port1, "NORTH")
  elk_graph_adapters_test_set_port_side(unordered_port2, "NORTH")

  let unordered_adapter = adapt_single_node(unordered)
  unordered_adapter.sort_port_list()
  let unordered_ports = unordered_adapter.get_ports()
  inspect(unordered_ports[0].get_port() == unordered_port1, content="true")
  inspect(unordered_ports[1].get_port() == unordered_port2, content="true")
}

///|
test "single port adapter exposes side labels edges and compound connections" {
  @graph.reset_graph_model_for_test()

  let root = @graph.create_graph()
  let owner = @graph.create_node(Some(root))
  let descendant = @graph.create_node(Some(owner))
  let outsider = @graph.create_node(Some(root))
  let port = @graph.create_port(Some(owner))
  elk_graph_adapters_test_set_port_side(port, "WEST")

  let label = @graph.create_label(Some(@graph.make_port_label_parent(port)))
  @graph.label_set_text(label, "p")
  elk_graph_adapters_test_set_label_side(label, "ABOVE")

  let incoming = @graph.create_edge(Some(root))
  @graph.edge_add_source(incoming, @graph.make_node_shape(descendant))
  @graph.edge_add_target(incoming, @graph.make_port_shape(port))

  let outgoing = @graph.create_edge(Some(root))
  @graph.edge_add_source(outgoing, @graph.make_port_shape(port))
  @graph.edge_add_target(outgoing, @graph.make_node_shape(outsider))

  let adapter = adapt_single_port(port)
  inspect(port_side_to_string(adapter.get_side()), content="WEST")
  inspect(adapter.get_labels().length(), content="1")
  inspect(adapter.get_labels()[0].get_text(), content="p")
  inspect(
    label_side_to_string(adapter.get_labels()[0].get_side()),
    content="ABOVE",
  )
  inspect(adapter.get_incoming_edges().length(), content="1")
  inspect(adapter.get_outgoing_edges().length(), content="1")
  inspect(adapter.has_compound_connections(), content="true")
}

///|
test "inside self loops yo is treated as compound connection" {
  @graph.reset_graph_model_for_test()

  let root = @graph.create_graph()
  let node = @graph.create_node(Some(root))
  let port = @graph.create_port(Some(node))

  let self_loop = @graph.create_edge(Some(root))
  @graph.edge_add_source(self_loop, @graph.make_port_shape(port))
  @graph.edge_add_target(self_loop, @graph.make_node_shape(node))
  @graph.edge_set_layout_option_string_by_id(
    self_loop, "org.eclipse.elk.insideSelfLoops.yo", "true",
  )

  let adapter = adapt_single_port(port)
  inspect(adapter.has_compound_connections(), content="true")
}

///|
test "padding and margin copy semantics follow Java behavior" {
  @graph.reset_graph_model_for_test()

  let root = @graph.create_graph()
  let node = @graph.create_node(Some(root))
  let port = @graph.create_port(Some(node))

  let node_adapter = adapt_single_node(node)
  let padding_value = new_elk_padding_any(3.0)
  node_adapter.set_padding(padding_value)
  padding_value.set_left(99.0)
  inspect(node_adapter.get_padding().left, content="3")

  let cloned_padding = node_adapter.get_padding()
  cloned_padding.set_left(55.0)
  inspect(node_adapter.get_padding().left, content="3")

  let node_margin = new_elk_margin_any(4.0)
  node_adapter.set_margin(node_margin)
  node_margin.set_left(88.0)
  inspect(node_adapter.get_margin().left, content="4")

  let cloned_margin = node_adapter.get_margin()
  cloned_margin.set_left(66.0)
  inspect(node_adapter.get_margin().left, content="4")

  let port_adapter = adapt_single_port(port)
  let port_margin = new_elk_margin_any(5.0)
  port_adapter.set_margin(port_margin)
  port_margin.set_left(77.0)
  inspect(port_adapter.get_margin().left, content="5")

  let cloned_port_margin = port_adapter.get_margin()
  cloned_port_margin.set_left(44.0)
  inspect(port_adapter.get_margin().left, content="5")
}
