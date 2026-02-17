///|
fn l_graph_util_test_connect(source : LPort, target : LPort) -> LEdge {
  let edge = new_l_edge()
  edge.set_source(Some(source))
  edge.set_target(Some(target))
  edge
}

///|
fn l_graph_util_test_node_type_long_edge() -> NodeType {
  node_type_values()[1]
}

///|
test "to_*_array returns copies" {
  let graph = new_l_graph()
  let node_a = new_l_node(graph=Some(graph))
  let node_b = new_l_node(graph=Some(graph))
  let port_a = new_l_port()
  let port_b = new_l_port()
  let edge = new_l_edge()

  let nodes = [node_a, node_b]
  let ports = [port_a, port_b]
  let edges = [edge]

  let copied_nodes = to_node_array(nodes)
  let copied_ports = to_port_array(ports)
  let copied_edges = to_edge_array(edges)

  ignore(copied_nodes.remove(0))
  ignore(copied_ports.remove(0))
  ignore(copied_edges.remove(0))

  inspect(nodes.length(), content="2")
  inspect(ports.length(), content="2")
  inspect(edges.length(), content="1")
}

///|
test "offset_graph moves nodes, bend points, junctions, and edge labels" {
  let graph = new_l_graph()
  let source_node = new_l_node(graph=Some(graph))
  let target_node = new_l_node(graph=Some(graph))
  graph.get_layerless_nodes().push(source_node)
  graph.get_layerless_nodes().push(target_node)

  ignore(source_node.get_position().set_xy(1.0, 2.0))
  ignore(target_node.get_position().set_xy(3.0, 4.0))

  let source_port = new_l_port()
  let target_port = new_l_port()
  source_node.add_port(source_port)
  target_node.add_port(target_port)

  let edge = l_graph_util_test_connect(source_port, target_port)
  edge.get_bend_points().add_xy(5.0, 6.0)
  let junction_points = new_kvector_chain()
  junction_points.add_xy(7.0, 8.0)
  edge.set_property_kvector_chain(
    layered_options_junction_points, junction_points,
  )
  let label = new_l_label()
  ignore(label.get_position().set_xy(9.0, 10.0))
  edge.get_labels().push(label)

  offset_graph(graph, 10.0, 20.0)

  inspect(source_node.get_position().x, content="11")
  inspect(source_node.get_position().y, content="22")
  inspect(target_node.get_position().x, content="13")
  inspect(target_node.get_position().y, content="24")
  inspect(edge.get_bend_points().get(0).x, content="15")
  inspect(edge.get_bend_points().get(0).y, content="26")
  inspect(
    edge.get_property_kvector_chain(layered_options_junction_points).get(0).x,
    content="17",
  )
  inspect(
    edge.get_property_kvector_chain(layered_options_junction_points).get(0).y,
    content="28",
  )
  inspect(label.get_position().x, content="19")
  inspect(label.get_position().y, content="30")
}

///|
test "offset_graphs offsets each graph" {
  let graph_a = new_l_graph()
  let node_a = new_l_node(graph=Some(graph_a))
  graph_a.get_layerless_nodes().push(node_a)
  ignore(node_a.get_position().set_xy(1.0, 1.0))

  let graph_b = new_l_graph()
  let node_b = new_l_node(graph=Some(graph_b))
  graph_b.get_layerless_nodes().push(node_b)
  ignore(node_b.get_position().set_xy(2.0, 3.0))

  offset_graphs([graph_a, graph_b], 4.0, 5.0)

  inspect(node_a.get_position().x, content="5")
  inspect(node_a.get_position().y, content="6")
  inspect(node_b.get_position().x, content="6")
  inspect(node_b.get_position().y, content="8")
}

///|
test "place_nodes_horizontally honors explicit alignments" {
  let graph = new_l_graph()
  let layer = new_layer(graph)
  ignore(layer.get_size().set_xy(100.0, layer.get_size().y))

  let left = new_l_node(graph=Some(graph))
  left.set_layer(Some(layer))
  ignore(left.get_size().set_xy(20.0, left.get_size().y))
  left.set_property_string(alignment, "LEFT")

  let center = new_l_node(graph=Some(graph))
  center.set_layer(Some(layer))
  ignore(center.get_size().set_xy(20.0, center.get_size().y))
  center.set_property_string(alignment, "CENTER")

  let right = new_l_node(graph=Some(graph))
  right.set_layer(Some(layer))
  ignore(right.get_size().set_xy(20.0, right.get_size().y))
  right.set_property_string(alignment, "RIGHT")

  place_nodes_horizontally(layer, 10.0)

  inspect(left.get_position().x, content="10")
  inspect(center.get_position().x, content="50")
  inspect(right.get_position().x, content="90")
}

///|
test "place_nodes_horizontally computes automatic ratio from port flow" {
  let graph = new_l_graph()
  let layer = new_layer(graph)
  ignore(layer.get_size().set_xy(120.0, layer.get_size().y))

  let source_node = new_l_node(graph=Some(graph))
  source_node.set_layer(Some(layer))
  ignore(source_node.get_size().set_xy(20.0, source_node.get_size().y))
  source_node.set_property_string(alignment, "AUTOMATIC")
  let source_port = new_l_port()
  source_node.add_port(source_port)

  let target_node = new_l_node(graph=Some(graph))
  target_node.set_layer(Some(layer))
  let target_port = new_l_port()
  target_node.add_port(target_port)
  ignore(l_graph_util_test_connect(source_port, target_port))

  place_nodes_horizontally(layer, 0.0)

  inspect(source_node.get_position().x, content="100")
}

///|
test "find_max_non_dummy_node_width respects margins and vertical direction" {
  let graph = new_l_graph()
  let layer = new_layer(graph)
  graph.get_layers().push(layer)

  let normal = new_l_node(graph=Some(graph))
  normal.set_layer(Some(layer))
  ignore(normal.get_size().set_xy(30.0, normal.get_size().y))
  normal.get_margin().set_left(3.0)
  normal.get_margin().set_right(4.0)

  let dummy = new_l_node(graph=Some(graph))
  dummy.set_layer(Some(layer))
  dummy.set_type(l_graph_util_test_node_type_long_edge())
  ignore(dummy.get_size().set_xy(999.0, dummy.get_size().y))

  graph.set_property_string(direction, "RIGHT")
  inspect(find_max_non_dummy_node_width(layer, false), content="30")
  inspect(find_max_non_dummy_node_width(layer, true), content="37")

  graph.set_property_string(direction, "DOWN")
  inspect(find_max_non_dummy_node_width(layer, true), content="0")
}
