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
fn l_graph_util_test_direction_rightward() -> Direction {
  direction_values()[1]
}

///|
fn l_graph_util_test_port_constraints_free() -> PortConstraints {
  port_constraints_values()[1]
}

///|
fn l_graph_util_test_port_constraints_fixed_side() -> PortConstraints {
  port_constraints_values()[2]
}

///|
fn l_graph_util_test_port_constraints_fixed_ratio() -> PortConstraints {
  port_constraints_values()[4]
}

///|
fn l_graph_util_test_port_type_input() -> PortType {
  port_type_values()[1]
}

///|
fn l_graph_util_test_port_type_output() -> PortType {
  port_type_values()[2]
}

///|
fn l_graph_util_test_port_side_west() -> PortSide {
  port_side_values()[4]
}

///|
fn l_graph_util_test_port_side_east() -> PortSide {
  port_side_values()[2]
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

///|
test "provide_collector_port reuses per-type collector ports" {
  let graph = new_l_graph()
  let node = new_l_node(graph=Some(graph))
  ignore(node.get_size().set_xy(40.0, 20.0))

  let in_collector = provide_collector_port(
    graph,
    node,
    l_graph_util_test_port_type_input(),
    l_graph_util_test_port_side_west(),
  )
  let in_collector_again = provide_collector_port(
    graph,
    node,
    l_graph_util_test_port_type_input(),
    l_graph_util_test_port_side_east(),
  )

  inspect(
    in_collector.get_handle() == in_collector_again.get_handle(),
    content="true",
  )
  inspect(
    in_collector.get_property_bool(internal_properties_input_collect),
    content="true",
  )
  inspect(port_side_to_string(in_collector.get_side()), content="WEST")
  inspect(in_collector.get_position().x, content="0")
  inspect(in_collector.get_position().y, content="10")

  let out_collector = provide_collector_port(
    graph,
    node,
    l_graph_util_test_port_type_output(),
    l_graph_util_test_port_side_east(),
  )
  inspect(
    out_collector.get_property_bool(internal_properties_output_collect),
    content="true",
  )
  inspect(port_side_to_string(out_collector.get_side()), content="EAST")
  inspect(out_collector.get_position().x, content="40")
  inspect(out_collector.get_position().y, content="10")
}

///|
test "initialize_port sets side, offset, ratio, and explicit anchor like Java" {
  let graph = new_l_graph()
  let node = new_l_node(graph=Some(graph))
  ignore(node.get_size().set_xy(10.0, 10.0))

  let side_port = new_l_port()
  side_port.set_node(Some(node))
  ignore(side_port.get_size().set_xy(2.0, 2.0))
  ignore(side_port.get_position().set_xy(11.0, 4.0))

  initialize_port(
    side_port,
    l_graph_util_test_port_constraints_fixed_side(),
    l_graph_util_test_direction_rightward(),
    None,
  )

  inspect(port_side_to_string(side_port.get_side()), content="EAST")
  inspect(
    side_port.get_property_double(layered_options_port_border_offset),
    content="1",
  )
  inspect(side_port.get_anchor().x, content="2")
  inspect(side_port.get_anchor().y, content="1")

  let ratio_port = new_l_port()
  ratio_port.set_node(Some(node))
  ignore(ratio_port.get_size().set_xy(2.0, 2.0))
  ignore(ratio_port.get_position().set_xy(5.0, 0.0))
  initialize_port(
    ratio_port,
    l_graph_util_test_port_constraints_fixed_ratio(),
    l_graph_util_test_direction_rightward(),
    None,
  )
  inspect(
    ratio_port.get_property_double(internal_properties_port_ratio_or_position),
    content="0.5",
  )

  let explicit_anchor_port = new_l_port()
  explicit_anchor_port.set_node(Some(node))
  ignore(explicit_anchor_port.get_size().set_xy(4.0, 6.0))
  let explicit_anchor = new_kvector_xy(3.0, 4.0)
  initialize_port(
    explicit_anchor_port,
    l_graph_util_test_port_constraints_free(),
    l_graph_util_test_direction_rightward(),
    Some(explicit_anchor),
  )
  inspect(explicit_anchor_port.get_anchor().x, content="3")
  inspect(explicit_anchor_port.get_anchor().y, content="4")
  inspect(
    explicit_anchor_port.is_explicitly_supplied_port_anchor(),
    content="true",
  )
}

///|
test "is_descendant_l_node follows parent graph chain" {
  let root_graph = new_l_graph()
  let root_node = new_l_node(graph=Some(root_graph))

  let child_graph = new_l_graph()
  child_graph.set_parent_node(Some(root_node))
  root_node.set_nested_graph(Some(child_graph))
  let child_node = new_l_node(graph=Some(child_graph))

  let grandchild_graph = new_l_graph()
  grandchild_graph.set_parent_node(Some(child_node))
  child_node.set_nested_graph(Some(grandchild_graph))
  let grandchild_node = new_l_node(graph=Some(grandchild_graph))

  inspect(is_descendant_l_node(child_node, root_node), content="true")
  inspect(is_descendant_l_node(grandchild_node, root_node), content="true")
  inspect(is_descendant_l_node(root_node, child_node), content="false")
}

///|
test "change_coord_system converts points between nested graph coordinate systems" {
  let root_graph = new_l_graph()
  root_graph.set_offset_xy(5.0, 7.0)

  let parent_node = new_l_node(graph=Some(root_graph))
  ignore(parent_node.get_position().set_xy(100.0, 200.0))

  let child_graph = new_l_graph()
  child_graph.set_parent_node(Some(parent_node))
  parent_node.set_nested_graph(Some(child_graph))
  child_graph.set_offset_xy(10.0, 20.0)
  child_graph.get_padding().set_left(3.0)
  child_graph.get_padding().set_top(4.0)

  let point_from_child = new_kvector_xy(1.0, 2.0)
  change_coord_system(point_from_child, child_graph, root_graph)
  inspect(point_from_child.x, content="114")
  inspect(point_from_child.y, content="226")

  let point_from_root = new_kvector_xy(114.0, 226.0)
  change_coord_system(point_from_root, root_graph, child_graph)
  inspect(point_from_root.x, content="1")
  inspect(point_from_root.y, content="2")

  let unchanged = new_kvector_xy(9.0, 9.0)
  change_coord_system(unchanged, child_graph, child_graph)
  inspect(unchanged.x, content="9")
  inspect(unchanged.y, content="9")
}
