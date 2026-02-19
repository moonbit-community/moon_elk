///|
fn breaking_point_remover_parse_edge_routing(value : String) -> @core.EdgeRouting {
  match value {
    "POLYLINE" => @core.EdgeRouting::Polyline
    "SPLINES" => @core.EdgeRouting::Splines
    "ORTHOGONAL" => @core.EdgeRouting::Orthogonal
    _ => @core.EdgeRouting::RoutingUndefined
  }
}

///|
fn breaking_point_remover_node_type_is_breaking_point(
  node_type : NodeType,
) -> Bool {
  match node_type {
    NodeType::BreakingPoint => true
    _ => false
  }
}

///|
fn[T] breaking_point_remover_reverse_array(values : Array[T]) -> Array[T] {
  let reversed = []
  let mut index = values.length()
  while index > 0 {
    index = index - 1
    reversed.push(values[index])
  }
  reversed
}

///|
fn[T] breaking_point_remover_add_all(
  target : Array[T],
  source : Array[T],
) -> Unit {
  for item in source {
    target.push(item)
  }
}

///|
pub struct BPInfo {
  start : LNode
  end : LNode
  node_start_edge : LEdge
  start_end_edge : LEdge
  original_edge : LEdge
  mut start_in_layer_dummy : LNode?
  mut start_in_layer_edge : LEdge?
  mut end_in_layer_dummy : LNode?
  mut end_in_layer_edge : LEdge?
  mut prev : BPInfo?
  mut next : BPInfo?
}

///|
pub fn new_bp_info(
  start : LNode,
  end : LNode,
  node_start_edge : LEdge,
  start_end_edge : LEdge,
  original_edge : LEdge,
) -> BPInfo {
  {
    start,
    end,
    node_start_edge,
    start_end_edge,
    original_edge,
    start_in_layer_dummy: None,
    start_in_layer_edge: None,
    end_in_layer_dummy: None,
    end_in_layer_edge: None,
    prev: None,
    next: None,
  }
}

///|
pub fn BPInfo::set_start_in_layer_dummy(self : BPInfo, value : LNode?) -> Unit {
  self.start_in_layer_dummy = value
}

///|
pub fn BPInfo::set_start_in_layer_edge(self : BPInfo, value : LEdge?) -> Unit {
  self.start_in_layer_edge = value
}

///|
pub fn BPInfo::set_end_in_layer_dummy(self : BPInfo, value : LNode?) -> Unit {
  self.end_in_layer_dummy = value
}

///|
pub fn BPInfo::set_end_in_layer_edge(self : BPInfo, value : LEdge?) -> Unit {
  self.end_in_layer_edge = value
}

///|
pub fn BPInfo::set_prev(self : BPInfo, value : BPInfo?) -> Unit {
  self.prev = value
}

///|
pub fn BPInfo::set_next(self : BPInfo, value : BPInfo?) -> Unit {
  self.next = value
}

///|
pub fn bp_info_is_start(node : LNode) -> Bool {
  if !breaking_point_remover_node_type_is_breaking_point(node.get_type()) {
    return false
  }
  match node.get_property_bp_info(internal_properties_breaking_point_info) {
    Some(info) =>
      lnode_internal_handle(info.start) == lnode_internal_handle(node)
    None => false
  }
}

///|
pub fn bp_info_is_end(node : LNode) -> Bool {
  if !breaking_point_remover_node_type_is_breaking_point(node.get_type()) {
    return false
  }
  match node.get_property_bp_info(internal_properties_breaking_point_info) {
    Some(info) => lnode_internal_handle(info.end) == lnode_internal_handle(node)
    None => false
  }
}

///|
fn breaking_point_remover_remove(
  graph : LGraph,
  bp_info : BPInfo,
  edge_routing_value : @core.EdgeRouting,
) -> Unit {
  ignore(graph)

  let new_bends = @core.new_kvector_chain()

  match edge_routing_value {
    @core.EdgeRouting::Splines => {
      let spline_segments_one = bp_info.node_start_edge.get_property_spline_segment_array(
        internal_properties_spline_route_start,
      )
      let spline_segments_two = bp_info.start_end_edge.get_property_spline_segment_array(
        internal_properties_spline_route_start,
      )
      let spline_segments_three = bp_info.original_edge.get_property_spline_segment_array(
        internal_properties_spline_route_start,
      )

      let spline_edges_one = bp_info.node_start_edge.get_property_l_edge_array(
        internal_properties_spline_edge_chain,
      )
      let spline_edges_two = bp_info.start_end_edge.get_property_l_edge_array(
        internal_properties_spline_edge_chain,
      )
      let spline_edges_three = bp_info.original_edge.get_property_l_edge_array(
        internal_properties_spline_edge_chain,
      )

      let joined_segments = []
      breaking_point_remover_add_all(joined_segments, spline_segments_one)

      let reversed_middle_segments = breaking_point_remover_reverse_array(
        spline_segments_two,
      )
      for segment in reversed_middle_segments {
        segment.inverse_order = true
        joined_segments.push(segment)
      }
      breaking_point_remover_add_all(joined_segments, spline_segments_three)

      let joined_edges = []
      breaking_point_remover_add_all(joined_edges, spline_edges_one)
      breaking_point_remover_add_all(
        joined_edges,
        breaking_point_remover_reverse_array(spline_edges_two),
      )
      breaking_point_remover_add_all(joined_edges, spline_edges_three)

      bp_info.original_edge.set_property_spline_segment_array(
        internal_properties_spline_route_start, joined_segments,
      )
      bp_info.original_edge.set_property_l_edge_array(
        internal_properties_spline_edge_chain, joined_edges,
      )
      bp_info.original_edge.set_property_l_edge(
        internal_properties_spline_surviving_edge,
        Some(bp_info.original_edge),
      )

      bp_info.node_start_edge.set_property_spline_segment_array(
        internal_properties_spline_route_start,
        [],
      )
      bp_info.node_start_edge.set_property_l_edge_array(
        internal_properties_spline_edge_chain,
        [],
      )
      bp_info.start_end_edge.set_property_spline_segment_array(
        internal_properties_spline_route_start,
        [],
      )
      bp_info.start_end_edge.set_property_l_edge_array(
        internal_properties_spline_edge_chain,
        [],
      )
    }
    @core.EdgeRouting::Polyline => {
      new_bends.add_all(bp_info.node_start_edge.get_bend_points().to_array())
      new_bends.add_vector(@core.new_kvector_copy(bp_info.start.get_position()))
      new_bends.add_all(
        breaking_point_remover_reverse_array(
          bp_info.start_end_edge.get_bend_points().to_array(),
        ),
      )
      new_bends.add_vector(@core.new_kvector_copy(bp_info.end.get_position()))
      new_bends.add_all(bp_info.original_edge.get_bend_points().to_array())
    }
    _ => {
      new_bends.add_all(bp_info.node_start_edge.get_bend_points().to_array())
      new_bends.add_all(
        breaking_point_remover_reverse_array(
          bp_info.start_end_edge.get_bend_points().to_array(),
        ),
      )
      new_bends.add_all(bp_info.original_edge.get_bend_points().to_array())
    }
  }

  bp_info.original_edge.get_bend_points().clear()
  bp_info.original_edge.get_bend_points().add_all(new_bends.to_array())
  bp_info.original_edge.set_source(bp_info.node_start_edge.get_source())

  let has_junctions_one = bp_info.node_start_edge.has_property_kvector_chain(
    layered_options_junction_points,
  )
  let has_junctions_two = bp_info.start_end_edge.has_property_kvector_chain(
    layered_options_junction_points,
  )
  let has_junctions_three = bp_info.original_edge.has_property_kvector_chain(
    layered_options_junction_points,
  )

  if has_junctions_one || has_junctions_two || has_junctions_three {
    let new_junctions = @core.new_kvector_chain()
    if has_junctions_three {
      new_junctions.add_all(
        bp_info.original_edge
        .get_property_kvector_chain(layered_options_junction_points)
        .to_array(),
      )
    }
    if has_junctions_two {
      new_junctions.add_all(
        bp_info.start_end_edge
        .get_property_kvector_chain(layered_options_junction_points)
        .to_array(),
      )
    }
    if has_junctions_one {
      new_junctions.add_all(
        bp_info.node_start_edge
        .get_property_kvector_chain(layered_options_junction_points)
        .to_array(),
      )
    }
    bp_info.original_edge.set_property_kvector_chain(
      layered_options_junction_points, new_junctions,
    )
  }

  bp_info.start_end_edge.set_source(None)
  bp_info.start_end_edge.set_target(None)
  bp_info.node_start_edge.set_source(None)
  bp_info.node_start_edge.set_target(None)
  bp_info.end.set_layer(None)
  bp_info.start.set_layer(None)

  match bp_info.prev {
    Some(previous) =>
      breaking_point_remover_remove(graph, previous, edge_routing_value)
    None => ()
  }
}

///|
fn breaking_point_remover_process(
  graph : LGraph,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => @core.new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("Breaking Point Removing", 1.0))

  let edge_routing_value = breaking_point_remover_parse_edge_routing(
    graph.get_property_string(@core.edge_routing),
  )
  for layer in graph.get_layers() {
    for node in layer.get_nodes().copy() {
      if bp_info_is_end(node) {
        match
          node.get_property_bp_info(internal_properties_breaking_point_info) {
          Some(info) =>
            if info.next is None {
              breaking_point_remover_remove(graph, info, edge_routing_value)
            }
          None => ()
        }
      }
    }
  }

  monitor.done()
}

///|
pub fn new_breaking_point_remover_layout_processor() -> @core.ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  @core.new_layout_processor(breaking_point_remover_process)
}
