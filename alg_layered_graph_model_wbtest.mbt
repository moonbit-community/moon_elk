///|
fn layered_graph_test_connect_nodes() -> (LGraph, LNode, LNode, LEdge, LEdge) {
  let graph = new_l_graph()

  let source = new_l_node(graph=Some(graph))
  source.set_id(1)
  let target = new_l_node(graph=Some(graph))
  target.set_id(2)
  graph.get_layerless_nodes().push(source)
  graph.get_layerless_nodes().push(target)

  let source_port = new_l_port()
  source_port.set_node(Some(source))
  let target_port = new_l_port()
  target_port.set_node(Some(target))

  let forward = new_l_edge()
  forward.set_source(Some(source_port))
  forward.set_target(Some(target_port))

  let backward = new_l_edge()
  backward.set_source(Some(target_port))
  backward.set_target(Some(source_port))

  (graph, source, target, forward, backward)
}

///|
test "LPort and LEdge keep bidirectional incidence lists in sync" {
  let (_graph, source, target, forward, _backward) = layered_graph_test_connect_nodes()
  let source_port = source.get_ports()[0]
  let target_port = target.get_ports()[0]

  assert_eq(source_port.get_outgoing_edges().length(), 1)
  assert_eq(source_port.get_incoming_edges().length(), 1)
  assert_eq(target_port.get_outgoing_edges().length(), 1)
  assert_eq(target_port.get_incoming_edges().length(), 1)

  let connected_from_source = source_port.get_connected_ports()
  assert_eq(connected_from_source.length(), 1)
  assert_eq(connected_from_source[0].get_node().unwrap().get_id(), 2)

  match forward.get_source() {
    Some(port) => assert_eq(port.get_node().unwrap().get_id(), 1)
    None => fail("forward edge should have a source")
  }
}

///|
test "Layer attaches nodes and exposes layer index" {
  let graph = new_l_graph()
  let layer = new_layer(graph)
  graph.get_layers().push(layer)

  let node = new_l_node(graph=Some(graph))
  node.set_layer(Some(layer))

  assert_eq(layer.get_nodes().length(), 1)
  assert_eq(layer.get_index(), 0)
  assert_eq(node.get_index(), 0)
}

///|
test "LNode border-to-content conversion uses graph padding and offset" {
  let graph = new_l_graph()
  graph.get_padding().left = 3.0
  graph.get_padding().top = 5.0
  graph.get_offset().x = 7.0
  graph.get_offset().y = 11.0

  let layer = new_layer(graph)
  graph.get_layers().push(layer)

  let node = new_l_node()
  node.get_position().x = 20.0
  node.get_position().y = 40.0
  node.set_layer(Some(layer))

  node.border_to_content_area_coordinates(true, true)

  assert_eq(node.get_position().x, 10.0)
  assert_eq(node.get_position().y, 24.0)
}

///|
test "LNode interactive reference point follows configured mode" {
  let graph = new_l_graph()
  let node = new_l_node(graph=Some(graph))
  node.get_position().x = 10.0
  node.get_position().y = 24.0
  node.get_size().x = 8.0
  node.get_size().y = 6.0

  let center_ref = node.get_interactive_reference_point()
  assert_eq(center_ref.x, 14.0)
  assert_eq(center_ref.y, 27.0)

  graph.set_property_string(
    layered_options_interactive_reference_point,
    interactive_reference_point_to_string(TopLeft),
  )
  let top_left_ref = node.get_interactive_reference_point()
  assert_eq(top_left_ref.x, 10.0)
  assert_eq(top_left_ref.y, 24.0)
}

///|
test "Tarjan detects a two-node strongly connected component" {
  let (graph, source, target, _forward, _backward) = layered_graph_test_connect_nodes()
  let tarjan = new_tarjan([])
  tarjan.tarjan(graph)

  let sccs = tarjan.get_strongly_connected_components()
  assert_eq(sccs.length(), 1)
  assert_eq(sccs[0].length(), 2)

  let node_map = tarjan.get_node_to_scc_id()
  assert_eq(node_map.get(source.get_handle()), Some(0))
  assert_eq(node_map.get(target.get_handle()), Some(0))
}

///|
test "Tarjan reset clears tarjan marks and cycle flags" {
  let (graph, source, _target, forward, _backward) = layered_graph_test_connect_nodes()

  source.set_property_bool(internal_properties_tarjan_on_stack, true)
  source.set_property_int(internal_properties_tarjan_lowlink, 7)
  source.set_property_int(internal_properties_tarjan_id, 9)
  forward.set_property_bool(internal_properties_is_part_of_cycle, true)

  let tarjan = new_tarjan([])
  tarjan.reset_tarjan(graph)

  assert_eq(
    source.get_property_bool(internal_properties_tarjan_on_stack),
    false,
  )
  assert_eq(source.get_property_int(internal_properties_tarjan_lowlink), -1)
  assert_eq(source.get_property_int(internal_properties_tarjan_id), -1)
  assert_eq(
    forward.get_property_bool(internal_properties_is_part_of_cycle),
    false,
  )
}
