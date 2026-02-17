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
fn l_graph_util_test_direction_leftward() -> Direction {
  direction_values()[2]
}

///|
fn l_graph_util_test_direction_undefined() -> Direction {
  direction_values()[0]
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
fn l_graph_util_test_port_constraints_fixed_order() -> PortConstraints {
  port_constraints_values()[3]
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
fn l_graph_util_test_port_side_north() -> PortSide {
  port_side_values()[1]
}

///|
fn l_graph_util_test_port_side_south() -> PortSide {
  port_side_values()[3]
}

///|
fn l_graph_util_test_node_type_external_port() -> NodeType {
  node_type_values()[2]
}

///|
let l_graph_util_test_layered_options_merge_edges : IProperty[Bool] = new_property(
  "org.eclipse.elk.layered.mergeEdges", false,
)

///|
fn l_graph_util_test_graph_has_property_name(
  graph : LGraph,
  expected_name : String,
) -> Bool {
  for
    property in graph.get_property_graph_properties_array(
      internal_properties_graph_properties,
    ) {
    if graph_properties_to_string(property) == expected_name {
      return true
    }
  }
  false
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
test "get_direction follows configured value or aspect-ratio fallback" {
  let graph = new_l_graph()
  graph.set_property_string(
    direction,
    direction_to_string(l_graph_util_test_direction_leftward()),
  )
  inspect(direction_to_string(get_direction(graph)), content="LEFT")

  graph.set_property_string(
    direction,
    direction_to_string(l_graph_util_test_direction_undefined()),
  )
  graph.set_property_double(aspect_ratio, 1.2)
  inspect(direction_to_string(get_direction(graph)), content="RIGHT")

  graph.set_property_double(aspect_ratio, 0.8)
  inspect(direction_to_string(get_direction(graph)), content="DOWN")
}

///|
test "get_individual_or_inherited follows node override then graph fallback" {
  let graph = new_l_graph()
  graph.set_property_double(spacing_edge_label, 17.0)

  let node = new_l_node(graph=Some(graph))
  inspect(get_individual_or_inherited(node, spacing_edge_label), content="17")

  node.set_property_double(spacing_edge_label, 3.0)
  inspect(get_individual_or_inherited(node, spacing_edge_label), content="3")
}

///|
test "compute_graph_properties follows LGraphUtil reference rules" {
  let graph = new_l_graph()
  graph.set_property_string(
    direction,
    direction_to_string(l_graph_util_test_direction_rightward()),
  )
  graph.set_property_graph_properties_array(
    internal_properties_graph_properties,
    [graph_properties_values()[9]],
  )

  let comment_node = new_l_node(graph=Some(graph))
  comment_node.set_property_bool(layered_options_comment_box, true)
  graph.get_layerless_nodes().push(comment_node)

  let hyper_node = new_l_node(graph=Some(graph))
  hyper_node.set_property_bool(layered_options_hypernode, true)
  graph.get_layerless_nodes().push(hyper_node)

  let external_node = new_l_node(graph=Some(graph))
  external_node.set_type(l_graph_util_test_node_type_external_port())
  graph.get_layerless_nodes().push(external_node)

  let undefined_port_constraints_node = new_l_node(graph=Some(graph))
  graph.get_layerless_nodes().push(undefined_port_constraints_node)

  let non_free_port_constraints_node = new_l_node(graph=Some(graph))
  non_free_port_constraints_node.set_property_string(
    port_constraints,
    port_constraints_to_string(l_graph_util_test_port_constraints_fixed_side()),
  )
  graph.get_layerless_nodes().push(non_free_port_constraints_node)

  let self_loop_node = new_l_node(graph=Some(graph))
  let self_loop_port = new_l_port()
  self_loop_port.set_node(Some(self_loop_node))
  self_loop_port.set_side(l_graph_util_test_port_side_north())
  let self_loop_edge = new_l_edge()
  self_loop_edge.set_source(Some(self_loop_port))
  self_loop_edge.set_target(Some(self_loop_port))
  let center_label = new_l_label()
  center_label.set_property_string(edge_labels_placement, "CENTER")
  self_loop_edge.get_labels().push(center_label)
  let end_label = new_l_label()
  end_label.set_property_string(edge_labels_placement, "HEAD")
  self_loop_edge.get_labels().push(end_label)
  graph.get_layerless_nodes().push(self_loop_node)

  compute_graph_properties(graph)

  inspect(
    l_graph_util_test_graph_has_property_name(graph, "PARTITIONS"),
    content="false",
  )
  inspect(
    l_graph_util_test_graph_has_property_name(graph, "COMMENTS"),
    content="true",
  )
  inspect(
    l_graph_util_test_graph_has_property_name(graph, "HYPERNODES"),
    content="true",
  )
  inspect(
    l_graph_util_test_graph_has_property_name(graph, "HYPEREDGES"),
    content="true",
  )
  inspect(
    l_graph_util_test_graph_has_property_name(graph, "EXTERNAL_PORTS"),
    content="true",
  )
  inspect(
    l_graph_util_test_graph_has_property_name(graph, "NON_FREE_PORTS"),
    content="true",
  )
  inspect(
    l_graph_util_test_graph_has_property_name(graph, "NORTH_SOUTH_PORTS"),
    content="true",
  )
  inspect(
    l_graph_util_test_graph_has_property_name(graph, "SELF_LOOPS"),
    content="true",
  )
  inspect(
    l_graph_util_test_graph_has_property_name(graph, "CENTER_LABELS"),
    content="true",
  )
  inspect(
    l_graph_util_test_graph_has_property_name(graph, "END_LABELS"),
    content="true",
  )
  inspect(
    undefined_port_constraints_node.get_property_string(port_constraints),
    content="FREE",
  )
}

///|
test "get_minimal_model_order returns max_value or minimum assigned order" {
  let empty_graph = new_l_graph()
  inspect(
    get_minimal_model_order(empty_graph) == @int.max_value,
    content="true",
  )

  let graph = new_l_graph()
  let node_without_order = new_l_node(graph=Some(graph))
  graph.get_layerless_nodes().push(node_without_order)

  let node_with_order_five = new_l_node(graph=Some(graph))
  node_with_order_five.set_property_int(internal_properties_model_order, 5)
  graph.get_layerless_nodes().push(node_with_order_five)

  let node_with_order_two = new_l_node(graph=Some(graph))
  node_with_order_two.set_property_int(internal_properties_model_order, 2)
  graph.get_layerless_nodes().push(node_with_order_two)

  inspect(get_minimal_model_order(graph), content="2")
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
test "resize_node follows Java port and label movement rules" {
  let graph = new_l_graph()
  let node = new_l_node(graph=Some(graph))
  ignore(node.get_size().set_xy(10.0, 10.0))

  let north_port = new_l_port()
  north_port.set_side(l_graph_util_test_port_side_north())
  ignore(north_port.get_position().set_xy(2.0, 0.0))
  node.add_port(north_port)

  let east_port = new_l_port()
  east_port.set_side(l_graph_util_test_port_side_east())
  ignore(east_port.get_position().set_xy(10.0, 3.0))
  node.add_port(east_port)

  let south_port = new_l_port()
  south_port.set_side(l_graph_util_test_port_side_south())
  ignore(south_port.get_position().set_xy(5.0, 10.0))
  node.add_port(south_port)

  let west_port = new_l_port()
  west_port.set_side(l_graph_util_test_port_side_west())
  ignore(west_port.get_position().set_xy(0.0, 4.0))
  node.add_port(west_port)

  let right_label = new_l_label()
  ignore(right_label.get_position().set_xy(8.0, 2.0))
  ignore(right_label.get_size().set_xy(2.0, 2.0))
  node.get_labels().push(right_label)

  let bottom_label = new_l_label()
  ignore(bottom_label.get_position().set_xy(2.0, 8.0))
  ignore(bottom_label.get_size().set_xy(2.0, 2.0))
  node.get_labels().push(bottom_label)

  resize_node(node, new_kvector_xy(20.0, 30.0), true, true)

  inspect(north_port.get_position().x, content="4")
  inspect(east_port.get_position().x, content="20")
  inspect(east_port.get_position().y, content="9")
  inspect(south_port.get_position().x, content="10")
  inspect(south_port.get_position().y, content="30")
  inspect(west_port.get_position().y, content="12")
  inspect(right_label.get_position().x, content="18")
  inspect(right_label.get_position().y, content="8")
  inspect(bottom_label.get_position().x, content="5")
  inspect(bottom_label.get_position().y, content="28")
  inspect(
    node.get_property_string_array(node_size_constraints).join(","),
    content="FIXED",
  )
}

///|
test "create_port_for_edge mirrors collector and side inference behavior" {
  let graph = new_l_graph()
  graph.set_property_string(
    direction,
    direction_to_string(l_graph_util_test_direction_rightward()),
  )

  let merge_node = new_l_node(graph=Some(graph))
  ignore(merge_node.get_size().set_xy(20.0, 20.0))
  graph.set_property_bool(l_graph_util_test_layered_options_merge_edges, true)

  let collector_a = create_port_for_edge(
    merge_node,
    None,
    l_graph_util_test_port_type_output(),
    graph,
  )
  let collector_b = create_port_for_edge(
    merge_node,
    None,
    l_graph_util_test_port_type_output(),
    graph,
  )
  inspect(collector_a.get_handle() == collector_b.get_handle(), content="true")
  inspect(port_side_to_string(collector_a.get_side()), content="EAST")

  graph.set_property_bool(l_graph_util_test_layered_options_merge_edges, false)
  let inferred_node = new_l_node(graph=Some(graph))
  ignore(inferred_node.get_size().set_xy(10.0, 10.0))
  ignore(inferred_node.get_position().set_xy(5.0, 7.0))

  let inferred_port = create_port_for_edge(
    inferred_node,
    Some(new_kvector_xy(8.0, 6.0)),
    l_graph_util_test_port_type_output(),
    graph,
  )
  inspect(inferred_port.get_position().x, content="3")
  inspect(inferred_port.get_position().y, content="0")
  inspect(port_side_to_string(inferred_port.get_side()), content="NORTH")
  inspect(
    l_graph_util_test_graph_has_property_name(graph, "NORTH_SOUTH_PORTS"),
    content="true",
  )
}

///|
test "external port dummy creation and position use Java formulas" {
  let graph = new_l_graph()
  graph.set_size_xy(100.0, 50.0)
  graph.get_padding().set_left(10.0)
  graph.get_padding().set_top(20.0)
  graph.get_padding().set_right(30.0)
  graph.get_padding().set_bottom(40.0)
  graph.set_offset_xy(3.0, 4.0)

  let holder = new_l_port()
  holder.set_side(l_graph_util_test_port_side_west())
  holder.set_property_double(layered_options_port_border_offset, -2.0)
  holder.set_property_int(layered_options_port_index, 5)

  let dummy = create_external_port_dummy(
    holder,
    l_graph_util_test_port_constraints_fixed_order(),
    l_graph_util_test_port_side_west(),
    1,
    Some(new_kvector_xy(100.0, 50.0)),
    Some(new_kvector_xy(20.0, 15.0)),
    new_kvector_xy(6.0, 8.0),
    l_graph_util_test_direction_rightward(),
    graph,
  )

  inspect(
    match dummy.get_type() {
      NodeType::ExternalPort => true
      _ => false
    },
    content="true",
  )
  inspect(dummy.get_size().x, content="2")
  inspect(dummy.get_size().y, content="8")
  let dummy_port = match dummy.get_ports().get(0) {
    Some(port) => port
    None => abort("Expected external port dummy to own one port.")
  }
  inspect(port_side_to_string(dummy_port.get_side()), content="EAST")
  inspect(dummy_port.get_position().x, content="0")
  inspect(dummy_port.get_position().y, content="4")
  inspect(
    dummy.get_property_double(internal_properties_port_ratio_or_position),
    content="-5",
  )
  inspect(
    port_side_to_string(
      dummy.get_property_port_side(internal_properties_ext_port_side),
    ),
    content="WEST",
  )

  let position = get_external_port_position(graph, dummy, 6.0, 8.0)
  inspect(position.x, content="-4")
  inspect(position.y, content="24")
  inspect(dummy.get_position().x, content="-11")

  let free_holder = new_l_port()
  let free_dummy = create_external_port_dummy(
    free_holder,
    l_graph_util_test_port_constraints_free(),
    port_side_values()[0],
    -1,
    None,
    None,
    new_kvector_xy(4.0, 4.0),
    l_graph_util_test_direction_rightward(),
    graph,
  )
  inspect(port_side_to_string(free_holder.get_side()), content="WEST")
  inspect(
    port_side_to_string(
      free_dummy.get_property_port_side(internal_properties_ext_port_side),
    ),
    content="WEST",
  )

  let ratio_holder = new_l_port()
  ratio_holder.set_side(l_graph_util_test_port_side_east())
  let ratio_dummy = create_external_port_dummy(
    ratio_holder,
    l_graph_util_test_port_constraints_fixed_ratio(),
    l_graph_util_test_port_side_east(),
    1,
    Some(new_kvector_xy(200.0, 120.0)),
    Some(new_kvector_xy(10.0, 30.0)),
    new_kvector_xy(4.0, 4.0),
    l_graph_util_test_direction_rightward(),
    graph,
  )
  inspect(
    ratio_dummy.get_property_double(internal_properties_port_ratio_or_position),
    content="0.25",
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
