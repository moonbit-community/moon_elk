///|
fn breaking_point_remover_test_port_side(name : String) -> @core.PortSide {
  for side in @core.port_side_values() {
    if @core.port_side_to_string(side) == name {
      return side
    }
  }
  abort("unknown side")
}

///|
fn breaking_point_remover_test_node_type(name : String) -> NodeType {
  for node_type in node_type_values() {
    match node_type {
      NodeType::Normal => if name == "NORMAL" { return node_type }
      NodeType::LongEdge => if name == "LONG_EDGE" { return node_type }
      NodeType::ExternalPort => if name == "EXTERNAL_PORT" { return node_type }
      NodeType::NorthSouthPort =>
        if name == "NORTH_SOUTH_PORT" {
          return node_type
        }
      NodeType::LabelNode => if name == "LABEL_NODE" { return node_type }
      NodeType::BreakingPoint =>
        if name == "BREAKING_POINT" {
          return node_type
        }
      NodeType::Placeholder => if name == "PLACEHOLDER" { return node_type }
      NodeType::NonshiftingPlaceholder =>
        if name == "NONSHIFTING_PLACEHOLDER" {
          return node_type
        }
    }
  }
  abort("unknown node type")
}

///|
fn breaking_point_remover_test_parse_edge_routing(name : String) -> @core.EdgeRouting {
  for routing in @core.edge_routing_values() {
    if @core.edge_routing_to_string(routing) == name {
      return routing
    }
  }
  abort("unknown edge routing")
}

///|
fn breaking_point_remover_test_make_chain(
  points : Array[(Double, Double)],
) -> @core.KVectorChain {
  let chain = @core.new_kvector_chain()
  for point in points {
    chain.add_xy(point.0, point.1)
  }
  chain
}

///|
fn breaking_point_remover_test_add_port(
  node : LNode,
  side_name : String,
) -> LPort {
  let port = new_l_port()
  port.set_node(Some(node))
  port.set_side(breaking_point_remover_test_port_side(side_name))
  port
}

///|
fn breaking_point_remover_test_connect(source : LPort, target : LPort) -> LEdge {
  let edge = new_l_edge()
  edge.set_source(Some(source))
  edge.set_target(Some(target))
  edge
}

///|
fn breaking_point_remover_test_build_single_breaking_point_graph(
  routing : @core.EdgeRouting,
) -> (LGraph, LNode, LNode, LNode, LNode, LEdge, LEdge, LEdge, LPort) {
  let graph = new_l_graph()
  graph.set_property_string(@core.edge_routing, @core.edge_routing_to_string(routing))

  let source_layer = new_layer(graph)
  let start_layer = new_layer(graph)
  let end_layer = new_layer(graph)
  let target_layer = new_layer(graph)
  graph.get_layers().push(source_layer)
  graph.get_layers().push(start_layer)
  graph.get_layers().push(end_layer)
  graph.get_layers().push(target_layer)

  let source = new_l_node(graph=Some(graph))
  source.set_layer(Some(source_layer))
  source.set_type(breaking_point_remover_test_node_type("NORMAL"))
  ignore(source.get_position().set_xy(0.0, 0.0))

  let start = new_l_node(graph=Some(graph))
  start.set_layer(Some(start_layer))
  start.set_type(breaking_point_remover_test_node_type("BREAKING_POINT"))
  ignore(start.get_position().set_xy(11.0, 12.0))

  let end = new_l_node(graph=Some(graph))
  end.set_layer(Some(end_layer))
  end.set_type(breaking_point_remover_test_node_type("BREAKING_POINT"))
  ignore(end.get_position().set_xy(21.0, 22.0))

  let target = new_l_node(graph=Some(graph))
  target.set_layer(Some(target_layer))
  target.set_type(breaking_point_remover_test_node_type("NORMAL"))
  ignore(target.get_position().set_xy(30.0, 0.0))

  let source_east = breaking_point_remover_test_add_port(source, "EAST")
  let start_west = breaking_point_remover_test_add_port(start, "WEST")
  let start_east = breaking_point_remover_test_add_port(start, "EAST")
  let end_west = breaking_point_remover_test_add_port(end, "WEST")
  let end_east = breaking_point_remover_test_add_port(end, "EAST")
  let target_west = breaking_point_remover_test_add_port(target, "WEST")

  let node_start_edge = breaking_point_remover_test_connect(
    source_east, start_west,
  )
  node_start_edge.get_bend_points().add_all([@core.new_kvector_xy(1.0, 1.0)])
  node_start_edge.set_property_kvector_chain(
    layered_options_junction_points,
    breaking_point_remover_test_make_chain([(101.0, 101.0)]),
  )

  let start_end_edge = breaking_point_remover_test_connect(start_east, end_west)
  start_end_edge
  .get_bend_points()
  .add_all([@core.new_kvector_xy(2.0, 2.0), @core.new_kvector_xy(3.0, 3.0)])
  start_end_edge.set_property_kvector_chain(
    layered_options_junction_points,
    breaking_point_remover_test_make_chain([(102.0, 102.0)]),
  )

  let original_edge = breaking_point_remover_test_connect(end_east, target_west)
  original_edge.get_bend_points().add_all([@core.new_kvector_xy(4.0, 4.0)])
  original_edge.set_property_kvector_chain(
    layered_options_junction_points,
    breaking_point_remover_test_make_chain([(103.0, 103.0)]),
  )

  let info = new_bp_info(
    start, end, node_start_edge, start_end_edge, original_edge,
  )
  start.set_property_bp_info(
    internal_properties_breaking_point_info,
    Some(info),
  )
  end.set_property_bp_info(internal_properties_breaking_point_info, Some(info))

  (
    graph, source, start, end, target, node_start_edge, start_end_edge, original_edge,
    source_east,
  )
}

///|
test "breaking point remover reports expected task name" {
  let processor = new_breaking_point_remover_layout_processor()
  let monitor = new_elk_progress_monitor()
  processor.process(new_l_graph(), Some(monitor))
  inspect(monitor.get_task_name(), content="Breaking Point Removing")
}

///|
test "breaking point remover polyline appends marker positions and restores original edge" {
  let (
    graph,
    _source,
    start,
    end,
    _target,
    node_start_edge,
    start_end_edge,
    original_edge,
    original_source_port,
  ) = breaking_point_remover_test_build_single_breaking_point_graph(
    breaking_point_remover_test_parse_edge_routing("POLYLINE"),
  )

  let processor = new_breaking_point_remover_layout_processor()
  processor.process(graph, None)

  assert_true(
    match original_edge.get_source() {
      Some(source) =>
        lport_internal_handle(source) ==
        lport_internal_handle(original_source_port)
      None => false
    },
  )

  let bends = original_edge.get_bend_points().to_array()
  assert_eq(bends.length(), 6)
  assert_eq(bends[0].x, 1.0)
  assert_eq(bends[1].x, 11.0)
  assert_eq(bends[2].x, 3.0)
  assert_eq(bends[3].x, 2.0)
  assert_eq(bends[4].x, 21.0)
  assert_eq(bends[5].x, 4.0)

  assert_true(start.get_layer() is None)
  assert_true(end.get_layer() is None)
  assert_true(node_start_edge.get_source() is None)
  assert_true(start_end_edge.get_target() is None)

  let joined_junctions = original_edge
    .get_property_kvector_chain(layered_options_junction_points)
    .to_array()
  assert_eq(joined_junctions.length(), 3)
  assert_eq(joined_junctions[0].x, 103.0)
  assert_eq(joined_junctions[1].x, 102.0)
  assert_eq(joined_junctions[2].x, 101.0)
}

///|
test "breaking point remover orthogonal skips start and end dummy positions" {
  let (
    graph,
    _source,
    _start,
    _end,
    _target,
    _node_start_edge,
    _start_end_edge,
    original_edge,
    _source_port,
  ) = breaking_point_remover_test_build_single_breaking_point_graph(
    breaking_point_remover_test_parse_edge_routing("ORTHOGONAL"),
  )

  let processor = new_breaking_point_remover_layout_processor()
  processor.process(graph, None)

  let bends = original_edge.get_bend_points().to_array()
  assert_eq(bends.length(), 4)
  assert_eq(bends[0].x, 1.0)
  assert_eq(bends[1].x, 3.0)
  assert_eq(bends[2].x, 2.0)
  assert_eq(bends[3].x, 4.0)
}
