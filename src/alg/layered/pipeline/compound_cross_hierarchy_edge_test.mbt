///|
fn compound_cross_hierarchy_test_west() -> @core.PortSide {
  @core.port_side_values()[4]
}

///|
fn compound_cross_hierarchy_test_east() -> @core.PortSide {
  @core.port_side_values()[2]
}

///|
fn compound_cross_hierarchy_test_port_type_input() -> PortType {
  port_type_values()[1]
}

///|
fn compound_cross_hierarchy_test_port_type_output() -> PortType {
  port_type_values()[2]
}

///|
fn compound_cross_hierarchy_test_external_port_node_type() -> NodeType {
  node_type_values()[2]
}

///|
fn compound_cross_hierarchy_test_add_node(graph : LGraph) -> LNode {
  let node = new_l_node(graph=Some(graph))
  graph.get_layerless_nodes().push(node)
  node
}

///|
fn compound_cross_hierarchy_test_add_port(
  node : LNode,
  side : @core.PortSide,
) -> LPort {
  let port = new_l_port()
  port.set_side(side)
  port.set_node(Some(node))
  node.add_port(port)
  port
}

///|
fn compound_cross_hierarchy_test_add_edge(graph : LGraph) -> LEdge {
  let source_node = compound_cross_hierarchy_test_add_node(graph)
  let target_node = compound_cross_hierarchy_test_add_node(graph)
  let source_port = compound_cross_hierarchy_test_add_port(
    source_node,
    compound_cross_hierarchy_test_east(),
  )
  let target_port = compound_cross_hierarchy_test_add_port(
    target_node,
    compound_cross_hierarchy_test_west(),
  )
  let edge = new_l_edge()
  edge.set_source(Some(source_port))
  edge.set_target(Some(target_port))
  edge
}

///|
test "CrossHierarchyEdge returns direct source and target ports for normal nodes" {
  let graph = new_l_graph()
  let source_node = compound_cross_hierarchy_test_add_node(graph)
  let target_node = compound_cross_hierarchy_test_add_node(graph)
  let source_port = compound_cross_hierarchy_test_add_port(
    source_node,
    compound_cross_hierarchy_test_east(),
  )
  let target_port = compound_cross_hierarchy_test_add_port(
    target_node,
    compound_cross_hierarchy_test_west(),
  )
  let edge = new_l_edge()
  edge.set_source(Some(source_port))
  edge.set_target(Some(target_port))

  let cross_hierarchy_edge = new_cross_hierarchy_edge(
    edge,
    graph,
    compound_cross_hierarchy_test_port_type_output(),
  )
  assert_eq(
    cross_hierarchy_edge.get_actual_source().get_handle(),
    source_port.get_handle(),
  )
  assert_eq(
    cross_hierarchy_edge.get_actual_target().get_handle(),
    target_port.get_handle(),
  )
}

///|
test "CrossHierarchyEdge resolves origin port for external port dummies" {
  let graph = new_l_graph()
  let dummy_source_node = compound_cross_hierarchy_test_add_node(graph)
  dummy_source_node.set_type(
    compound_cross_hierarchy_test_external_port_node_type(),
  )
  let dummy_source_port = compound_cross_hierarchy_test_add_port(
    dummy_source_node,
    compound_cross_hierarchy_test_east(),
  )
  let target_node = compound_cross_hierarchy_test_add_node(graph)
  let target_port = compound_cross_hierarchy_test_add_port(
    target_node,
    compound_cross_hierarchy_test_west(),
  )
  let origin_source_node = compound_cross_hierarchy_test_add_node(graph)
  let origin_source_port = compound_cross_hierarchy_test_add_port(
    origin_source_node,
    compound_cross_hierarchy_test_east(),
  )
  dummy_source_node.set_property_l_port(
    internal_properties_origin_l_port,
    Some(origin_source_port),
  )

  let source_edge = new_l_edge()
  source_edge.set_source(Some(dummy_source_port))
  source_edge.set_target(Some(target_port))
  let source_cross_edge = new_cross_hierarchy_edge(
    source_edge,
    graph,
    compound_cross_hierarchy_test_port_type_output(),
  )
  assert_eq(
    source_cross_edge.get_actual_source().get_handle(),
    origin_source_port.get_handle(),
  )

  let dummy_target_node = compound_cross_hierarchy_test_add_node(graph)
  dummy_target_node.set_type(
    compound_cross_hierarchy_test_external_port_node_type(),
  )
  let dummy_target_port = compound_cross_hierarchy_test_add_port(
    dummy_target_node,
    compound_cross_hierarchy_test_west(),
  )
  let source_node = compound_cross_hierarchy_test_add_node(graph)
  let source_port = compound_cross_hierarchy_test_add_port(
    source_node,
    compound_cross_hierarchy_test_east(),
  )
  let origin_target_node = compound_cross_hierarchy_test_add_node(graph)
  let origin_target_port = compound_cross_hierarchy_test_add_port(
    origin_target_node,
    compound_cross_hierarchy_test_west(),
  )
  dummy_target_node.set_property_l_port(
    internal_properties_origin_l_port,
    Some(origin_target_port),
  )

  let target_edge = new_l_edge()
  target_edge.set_source(Some(source_port))
  target_edge.set_target(Some(dummy_target_port))
  let target_cross_edge = new_cross_hierarchy_edge(
    target_edge,
    graph,
    compound_cross_hierarchy_test_port_type_input(),
  )
  assert_eq(
    target_cross_edge.get_actual_target().get_handle(),
    origin_target_port.get_handle(),
  )
}

///|
test "CrossHierarchyEdgeComparator orders output before input and respects depth" {
  let top_graph = new_l_graph()
  let nested_graph = new_l_graph()
  let nested_parent = new_l_node(graph=Some(top_graph))
  nested_graph.set_parent_node(Some(nested_parent))
  let deep_graph = new_l_graph()
  let deep_parent = new_l_node(graph=Some(nested_graph))
  deep_graph.set_parent_node(Some(deep_parent))

  let top_output = new_cross_hierarchy_edge(
    compound_cross_hierarchy_test_add_edge(top_graph),
    top_graph,
    compound_cross_hierarchy_test_port_type_output(),
  )
  let deep_output = new_cross_hierarchy_edge(
    compound_cross_hierarchy_test_add_edge(deep_graph),
    deep_graph,
    compound_cross_hierarchy_test_port_type_output(),
  )
  let top_input = new_cross_hierarchy_edge(
    compound_cross_hierarchy_test_add_edge(top_graph),
    top_graph,
    compound_cross_hierarchy_test_port_type_input(),
  )
  let deep_input = new_cross_hierarchy_edge(
    compound_cross_hierarchy_test_add_edge(deep_graph),
    deep_graph,
    compound_cross_hierarchy_test_port_type_input(),
  )
  let comparator = new_cross_hierarchy_edge_comparator(top_graph)

  assert_true(comparator.compare(deep_output, top_input) < 0)
  assert_true(comparator.compare(top_input, deep_output) > 0)
  assert_true(comparator.compare(deep_output, top_output) < 0)
  assert_true(comparator.compare(top_input, deep_input) < 0)
}
