///|
fn long_edge_joiner_node_type_equals(left : NodeType, right : NodeType) -> Bool {
  match (left, right) {
    (NodeType::Normal, NodeType::Normal) => true
    (NodeType::LongEdge, NodeType::LongEdge) => true
    (NodeType::ExternalPort, NodeType::ExternalPort) => true
    (NodeType::NorthSouthPort, NodeType::NorthSouthPort) => true
    (NodeType::LabelNode, NodeType::LabelNode) => true
    (NodeType::BreakingPoint, NodeType::BreakingPoint) => true
    (NodeType::Placeholder, NodeType::Placeholder) => true
    (NodeType::NonshiftingPlaceholder, NodeType::NonshiftingPlaceholder) => true
    _ => false
  }
}

///|
fn long_edge_joiner_port_side_equals(
  left : @core.PortSide,
  right : @core.PortSide,
) -> Bool {
  match (left, right) {
    (@core.PortSide::North, @core.PortSide::North) => true
    (@core.PortSide::East, @core.PortSide::East) => true
    (@core.PortSide::South, @core.PortSide::South) => true
    (@core.PortSide::West, @core.PortSide::West) => true
    (@core.PortSide::SideUndefined, @core.PortSide::SideUndefined) => true
    _ => false
  }
}

///|
fn _long_edge_joiner_require_source(edge : LEdge) -> LPort {
  match edge.get_source() {
    Some(value) => value
    None => abort("edge has no source")
  }
}

///|
fn long_edge_joiner_require_target(edge : LEdge) -> LPort {
  match edge.get_target() {
    Some(value) => value
    None => abort("edge has no target")
  }
}

///|
fn long_edge_joiner_port_side_ports(
  node : LNode,
  side : @core.PortSide,
) -> Array[LPort] {
  let result = []
  for port in node.get_ports() {
    if long_edge_joiner_port_side_equals(port.get_side(), side) {
      result.push(port)
    }
  }
  result
}

///|
fn long_edge_joiner_edge_index(edges : Array[LEdge], edge : LEdge) -> Int {
  for i in 0..<edges.length() {
    if ledge_internal_handle(edges[i]) == ledge_internal_handle(edge) {
      return i
    }
  }
  -1
}

///|
fn long_edge_joiner_set_target_and_insert_at_index(
  edge : LEdge,
  new_target : LPort,
  target_index : Int,
) -> Unit {
  edge.set_target(Some(new_target))
  let incoming = new_target.get_incoming_edges()
  let edge_index = long_edge_joiner_edge_index(incoming, edge)
  if edge_index < 0 {
    return
  }

  let moved = incoming.remove(edge_index)
  let insert_index = if target_index < 0 {
    0
  } else if target_index > incoming.length() {
    incoming.length()
  } else {
    target_index
  }
  ignore(incoming.insert(insert_index, moved))
}

///|
pub fn long_edge_joiner_join_at(
  long_edge_dummy : LNode,
  add_unnecessary_bendpoints : Bool,
) -> Unit {
  let west_ports = long_edge_joiner_port_side_ports(
    long_edge_dummy,
    @core.PortSide::West,
  )
  let east_ports = long_edge_joiner_port_side_ports(
    long_edge_dummy,
    @core.PortSide::East,
  )
  if west_ports.is_empty() || east_ports.is_empty() {
    return
  }

  let input_port_edges = west_ports[0].get_incoming_edges()
  let output_port_edges = east_ports[0].get_outgoing_edges()
  let mut edge_count = input_port_edges.length()
  let unnecessary_bendpoint = long_edge_dummy.get_ports()[0].get_absolute_anchor()

  while edge_count > 0 {
    let surviving_edge = input_port_edges[0]
    let dropped_edge = output_port_edges[0]

    let dropped_target = long_edge_joiner_require_target(dropped_edge)
    let target_incoming_edges = dropped_target.get_incoming_edges()
    let dropped_edge_list_index = long_edge_joiner_edge_index(
      target_incoming_edges, dropped_edge,
    )

    long_edge_joiner_set_target_and_insert_at_index(
      surviving_edge, dropped_target, dropped_edge_list_index,
    )

    dropped_edge.set_source(None)
    dropped_edge.set_target(None)

    let surviving_bend_points = surviving_edge.get_bend_points()
    if add_unnecessary_bendpoints {
      surviving_bend_points.add_vector(
        @core.new_kvector_copy(unnecessary_bendpoint),
      )
    }
    for bend_point in dropped_edge.get_bend_points().to_array() {
      surviving_bend_points.add_vector(@core.new_kvector_copy(bend_point))
    }

    let surviving_labels = surviving_edge.get_labels()
    for label in dropped_edge.get_labels() {
      surviving_labels.push(label)
    }

    if dropped_edge.has_property_kvector_chain(layered_options_junction_points) {
      let dropped_junction_points = dropped_edge.get_property_kvector_chain(
        layered_options_junction_points,
      )
      if !surviving_edge.has_property_kvector_chain(
          layered_options_junction_points,
        ) {
        surviving_edge.set_property_kvector_chain(
          layered_options_junction_points,
          @core.new_kvector_chain(),
        )
      }

      let surviving_junction_points = surviving_edge.get_property_kvector_chain(
        layered_options_junction_points,
      )
      for junction_point in dropped_junction_points.to_array() {
        surviving_junction_points.add_vector(
          @core.new_kvector_copy(junction_point),
        )
      }
    }

    edge_count = edge_count - 1
  }
}

///|
fn long_edge_joiner_process(
  layered_graph : LGraph,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => @core.new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("Edge joining", 1.0))

  let add_unnecessary_bendpoints = layered_graph.get_property_bool(
    layered_options_unnecessary_bendpoints,
  )

  for layer in layered_graph.get_layers() {
    let layer_nodes = layer.get_nodes()
    let mut index = 0
    while index < layer_nodes.length() {
      let node = layer_nodes[index]
      if long_edge_joiner_node_type_equals(node.get_type(), NodeType::LongEdge) {
        long_edge_joiner_join_at(node, add_unnecessary_bendpoints)
        ignore(layer_nodes.remove(index))
      } else {
        index = index + 1
      }
    }
  }

  monitor.done()
}

///|
pub fn new_long_edge_joiner_layout_processor() -> @core.ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  @core.new_layout_processor(long_edge_joiner_process)
}
