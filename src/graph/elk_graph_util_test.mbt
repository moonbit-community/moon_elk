///|
fn create_edge_without_containment(
  source~ : ElkConnectableShape?,
  target~ : ElkConnectableShape?,
) -> ElkEdge {
  let edge = create_edge(None)
  if source is Some(source) {
    edge_add_source(edge, source)
  }
  if target is Some(target) {
    edge_add_target(edge, target)
  }
  edge
}

///|
test "ElkGraphUtil connectableShapeToNode" {
  reset_graph_model_for_test()
  let node = create_node(None)
  assert_eq(connectable_shape_to_node(Some(make_node_shape(node))), node)
  let port = create_port(Some(node))
  assert_eq(connectable_shape_to_node(Some(make_port_shape(port))), node)
}

///|
test "panic ElkGraphUtil connectableShapeToNode with none" {
  ignore(connectable_shape_to_node(None))
}

///|
test "ElkGraphUtil connectableShapeToPort" {
  reset_graph_model_for_test()
  let node = create_node(None)
  assert_eq(connectable_shape_to_port(Some(make_node_shape(node))), None)
  let port = create_port(Some(node))
  assert_eq(connectable_shape_to_port(Some(make_port_shape(port))), Some(port))
}

///|
test "panic ElkGraphUtil connectableShapeToPort with none" {
  ignore(connectable_shape_to_port(None))
}

///|
test "ElkGraphUtil edge convenience iterables" {
  reset_graph_model_for_test()
  let graph = create_graph()
  let node1 = create_node(Some(graph))
  let node2 = create_node(Some(graph))
  let node3 = create_node(Some(graph))
  let port1 = create_port(Some(node1))
  let port2 = create_port(Some(node2))

  let edge0 = create_edge_without_containment(
    source=Some(make_node_shape(node1)),
    target=Some(make_node_shape(node2)),
  )
  let edge1 = create_edge_without_containment(
    source=Some(make_port_shape(port1)),
    target=Some(make_node_shape(node2)),
  )
  let edge2 = create_edge_without_containment(
    source=Some(make_node_shape(node3)),
    target=Some(make_port_shape(port2)),
  )
  let edge3 = create_edge_without_containment(
    source=Some(make_port_shape(port1)),
    target=Some(make_port_shape(port2)),
  )
  let edge4 = create_edge_without_containment(
    source=Some(make_node_shape(node2)),
    target=Some(make_node_shape(node3)),
  )

  assert_eq(all_outgoing_edges(node1), [edge0, edge1, edge3])
  assert_eq(all_incoming_edges(node2), [edge0, edge1, edge2, edge3])
  assert_eq(all_incident_edges(node2), [edge4, edge0, edge1, edge2, edge3])

  assert_eq(all_incident_edges_for_shape(make_node_shape(node2)), [
    edge0, edge1, edge4,
  ])
  assert_eq(all_incident_edges_for_shape(make_port_shape(port2)), [edge2, edge3])
  let incident_shapes = all_incident_shapes(edge3)
  assert_eq(incident_shapes.length(), 2)
  match incident_shapes[0] {
    PortShape(port) => assert_eq(port, port1)
    _ => fail("Expected source port shape")
  }
  match incident_shapes[1] {
    PortShape(port) => assert_eq(port, port2)
    _ => fail("Expected target port shape")
  }
}

///|
test "ElkGraphUtil allIncidentSections" {
  reset_graph_model_for_test()
  let edge = create_edge(None)
  let section0 = create_edge_section(edge)
  let section1 = create_edge_section(edge)
  let section2 = create_edge_section(edge)

  edge_section_add_incoming_section(section0, section1)
  edge_section_add_outgoing_section(section0, section2)

  assert_eq(all_incident_sections(section0), [section1, section2])
}

///|
test "ElkGraphUtil createLabelWithText" {
  reset_graph_model_for_test()
  let graph = create_graph()
  let node = create_node(Some(graph))
  let label = create_label_with_text(
    "hello",
    Some(make_node_label_parent(node)),
  )

  assert_eq(label_text(label), "hello")
  match label_parent(label) {
    Some(NodeLabelParent(parent_node)) => assert_eq(parent_node, node)
    _ => fail("Expected node label parent")
  }
}

///|
test "ElkGraphUtil createHyperedge" {
  reset_graph_model_for_test()
  let graph = create_graph()
  let node1 = create_node(Some(graph))
  let node2 = create_node(Some(graph))
  let compound = create_node(Some(graph))
  let child = create_node(Some(compound))

  let edge = create_hyperedge(
    [make_node_shape(node1), make_node_shape(child)],
    [make_node_shape(node2)],
  )

  assert_eq(edge_sources(edge).length(), 2)
  assert_eq(edge_targets(edge).length(), 1)
  match edge_sources(edge)[0] {
    NodeShape(node) => assert_eq(node, node1)
    _ => fail("Expected node source")
  }
  match edge_sources(edge)[1] {
    NodeShape(node) => assert_eq(node, child)
    _ => fail("Expected node source")
  }
  match edge_targets(edge)[0] {
    NodeShape(node) => assert_eq(node, node2)
    _ => fail("Expected node target")
  }
  assert_eq(edge_containing_node(edge), Some(graph))
}

///|
test "ElkGraphUtil createSimpleEdgeForShapes" {
  reset_graph_model_for_test()
  let graph = create_graph()
  let node1 = create_node(Some(graph))
  let node2 = create_node(Some(graph))
  let port1 = create_port(Some(node1))
  let port2 = create_port(Some(node2))

  let edge = create_simple_edge_for_shapes(
    make_port_shape(port1),
    make_port_shape(port2),
  )

  assert_eq(edge_sources(edge).length(), 1)
  assert_eq(edge_targets(edge).length(), 1)
  match edge_sources(edge)[0] {
    PortShape(port) => assert_eq(port, port1)
    _ => fail("Expected port source")
  }
  match edge_targets(edge)[0] {
    PortShape(port) => assert_eq(port, port2)
    _ => fail("Expected port target")
  }
  assert_eq(edge_containing_node(edge), Some(graph))
}

///|
test "ElkGraphUtil findBestEdgeContainment" {
  reset_graph_model_for_test()
  let graph1 = create_graph()
  let node1 = create_node(Some(graph1))
  let node2 = create_node(Some(graph1))
  let node3 = create_node(Some(graph1))
  let node3_1 = create_node(Some(node3))
  let node3_1_1 = create_node(Some(node3_1))
  let node4 = create_node(Some(graph1))
  let node4_1 = create_node(Some(node4))
  let graph2 = create_graph()
  let node_a = create_node(Some(graph2))
  let same_level_edge = create_edge_without_containment(
    source=Some(make_node_shape(node1)),
    target=Some(make_node_shape(node2)),
  )
  assert_eq(find_best_edge_containment(Some(same_level_edge)), Some(graph1))
  let self_loop_edge = create_edge_without_containment(
    source=Some(make_node_shape(node1)),
    target=Some(make_node_shape(node1)),
  )
  assert_eq(find_best_edge_containment(Some(self_loop_edge)), Some(graph1))
  let down_level_edge = create_edge_without_containment(
    source=Some(make_node_shape(node1)),
    target=Some(make_node_shape(node3_1)),
  )
  assert_eq(find_best_edge_containment(Some(down_level_edge)), Some(graph1))
  let up_level_edge = create_edge_without_containment(
    source=Some(make_node_shape(node3_1)),
    target=Some(make_node_shape(node2)),
  )
  assert_eq(find_best_edge_containment(Some(up_level_edge)), Some(graph1))
  let to_child_edge = create_edge_without_containment(
    source=Some(make_node_shape(node3)),
    target=Some(make_node_shape(node3_1)),
  )
  assert_eq(find_best_edge_containment(Some(to_child_edge)), Some(node3))
  let to_parent_edge = create_edge_without_containment(
    source=Some(make_node_shape(node3_1)),
    target=Some(make_node_shape(node3)),
  )
  assert_eq(find_best_edge_containment(Some(to_parent_edge)), Some(node3))
  let to_grand_child_edge = create_edge_without_containment(
    source=Some(make_node_shape(node3)),
    target=Some(make_node_shape(node3_1_1)),
  )
  assert_eq(find_best_edge_containment(Some(to_grand_child_edge)), Some(node3))
  let to_grand_parent_edge = create_edge_without_containment(
    source=Some(make_node_shape(node3_1_1)),
    target=Some(make_node_shape(node3)),
  )
  assert_eq(find_best_edge_containment(Some(to_grand_parent_edge)), Some(node3))
  let cross_hierarchy_edge = create_edge_without_containment(
    source=Some(make_node_shape(node3_1)),
    target=Some(make_node_shape(node4_1)),
  )
  assert_eq(
    find_best_edge_containment(Some(cross_hierarchy_edge)),
    Some(graph1),
  )
  let cross_graph_edge = create_edge_without_containment(
    source=Some(make_node_shape(node1)),
    target=Some(make_node_shape(node_a)),
  )
  assert_eq(find_best_edge_containment(Some(cross_graph_edge)), None)
  let source_missing_edge = create_edge_without_containment(
    source=None,
    target=Some(make_node_shape(node1)),
  )
  assert_eq(find_best_edge_containment(Some(source_missing_edge)), Some(graph1))
  let target_missing_edge = create_edge_without_containment(
    source=Some(make_node_shape(node1)),
    target=None,
  )
  assert_eq(find_best_edge_containment(Some(target_missing_edge)), Some(graph1))
}

///|
test "panic ElkGraphUtil findBestEdgeContainment with unconnected edge" {
  reset_graph_model_for_test()
  let edge = create_edge(None)
  ignore(find_best_edge_containment(Some(edge)))
}

///|
test "panic ElkGraphUtil findBestEdgeContainment with none" {
  ignore(find_best_edge_containment(None))
}
