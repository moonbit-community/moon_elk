///|
priv suberror FinalSplineBendpointsCalculatorException {
  IllegalArgumentException(String)
} derive(Show, ToJson)

///|
fn[T] final_spline_raise_illegal_argument(
  message : String,
) -> T raise FinalSplineBendpointsCalculatorException {
  raise FinalSplineBendpointsCalculatorException::IllegalArgumentException(
    message,
  )
}

///|
let final_spline_one_half : Double = 0.5

///|
pub let final_spline_node_to_straightening_cp_gap : Double = 5.0

///|
let final_spline_sloppy_center_cp_multiplier : Double = 0.4

///|
fn final_spline_port_side_equals(
  left : @core.PortSide,
  right : @core.PortSide,
) -> Bool {
  match (left, right) {
    (North, North) => true
    (East, East) => true
    (South, South) => true
    (West, West) => true
    (@core.SideUndefined, @core.SideUndefined) => true
    _ => false
  }
}

///|
fn final_spline_port_side_in_array(
  side : @core.PortSide,
  sides : Array[@core.PortSide],
) -> Bool {
  for candidate in sides {
    if final_spline_port_side_equals(side, candidate) {
      return true
    }
  }
  false
}

///|
fn final_spline_spline_routing_mode_equals(
  left : SplineRoutingMode,
  right : SplineRoutingMode,
) -> Bool {
  match (left, right) {
    (Conservative, Conservative) => true
    (ConservativeSoft, ConservativeSoft) => true
    (Sloppy, Sloppy) => true
    _ => false
  }
}

///|
fn final_spline_graph_compaction_strategy_equals(
  left : GraphCompactionStrategy,
  right : GraphCompactionStrategy,
) -> Bool {
  match (left, right) {
    (NoneType, NoneType) => true
    (Left, Left) => true
    (Right, Right) => true
    (LeftRightConstraintLocking, LeftRightConstraintLocking) => true
    (LeftRightConnectionLocking, LeftRightConnectionLocking) => true
    (EdgeLength, EdgeLength) => true
    _ => false
  }
}

///|
fn final_spline_parse_graph_compaction_strategy(
  value : String,
) -> GraphCompactionStrategy {
  let normalized = value.trim().to_string().to_upper()
  match normalized {
    "LEFT" => Left
    "RIGHT" => Right
    "LEFT_RIGHT_CONSTRAINT_LOCKING" => LeftRightConstraintLocking
    "LEFT_RIGHT_CONNECTION_LOCKING" => LeftRightConnectionLocking
    "EDGE_LENGTH" => EdgeLength
    _ => NoneType
  }
}

///|
fn final_spline_require_edge_source(edge : LEdge) -> LPort {
  edge.get_source().unwrap()
}

///|
fn final_spline_require_edge_target(edge : LEdge) -> LPort {
  edge.get_target().unwrap()
}

///|
fn final_spline_require_port_node(port : LPort) -> LNode {
  port.get_node().unwrap()
}

///|
fn final_spline_require_node_layer(node : LNode) -> Layer {
  node.get_layer().unwrap()
}

///|
fn final_spline_require_segment_source_port(segment : SplineSegment) -> LPort {
  segment.source_port.unwrap()
}

///|
fn final_spline_require_segment_target_port(segment : SplineSegment) -> LPort {
  segment.target_port.unwrap()
}

///|
fn final_spline_require_edge_information(
  segment : SplineSegment,
  edge : LEdge,
) -> SplineSegmentEdgeInformation {
  segment.get_edge_information(edge).unwrap()
}

///|
fn final_spline_index_nodes_per_layer(graph : LGraph) -> Unit {
  for layer in graph.get_layers() {
    let layer_nodes = layer.get_nodes()
    for i in 0..<layer_nodes.length() {
      layer_nodes[i].set_id(i)
    }
  }
}

///|
fn final_spline_collect_start_edges(graph : LGraph) -> Array[LEdge] {
  let start_edges : Array[LEdge] = []
  for layer in graph.get_layers() {
    for node in layer.get_nodes() {
      for edge in node.get_outgoing_edges() {
        if edge.is_self_loop() {
          continue
        }
        if !edge.has_property_spline_segment_array(
            internal_properties_spline_route_start,
          ) {
          continue
        }
        start_edges.push(edge)
      }
    }
  }
  start_edges
}

///|
fn final_spline_calculate_control_points_straight(
  segment : SplineSegment,
) -> Unit {
  if segment.edges.is_empty() {
    return
  }
  let x_start_pos = segment.bounding_box.x
  let x_end_pos = segment.bounding_box.x + segment.bounding_box.width
  let halfway = @core.new_kvector_xy(
    x_start_pos + (x_end_pos - x_start_pos) / 2.0,
    segment.center_control_point_y,
  )
  segment.edges[0].get_bend_points().add_vector(halfway)
}

///|
fn final_spline_calculate_control_points_inverted_edge(
  edge : LEdge,
  containing_segment : SplineSegment,
  edge_edge_spacing : Double,
  edge_node_spacing : Double,
) -> Unit {
  let start_x_pos = containing_segment.bounding_box.x
  let end_x_pos = containing_segment.bounding_box.x +
    containing_segment.bounding_box.width

  let edge_info = final_spline_require_edge_information(
    containing_segment, edge,
  )
  let y_source_anchor = edge_info.start_y
  let y_target_anchor = edge_info.end_y

  let source_straight_cp = if edge_info.inverted_left {
    @core.new_kvector_xy(end_x_pos, y_source_anchor)
  } else {
    @core.new_kvector_xy(start_x_pos, y_source_anchor)
  }
  let target_straight_cp = if edge_info.inverted_right {
    @core.new_kvector_xy(start_x_pos, y_target_anchor)
  } else {
    @core.new_kvector_xy(end_x_pos, y_target_anchor)
  }

  let mut center_x_pos = start_x_pos
  if !containing_segment.is_west_of_initial_layer {
    center_x_pos += edge_node_spacing
  }
  center_x_pos += containing_segment.x_delta +
    containing_segment.rank.to_double() * edge_edge_spacing

  let source_vertical_cp = @core.new_kvector_xy(center_x_pos, y_source_anchor)
  let target_vertical_cp = @core.new_kvector_xy(center_x_pos, y_target_anchor)

  let bend_points = edge.get_bend_points()
  bend_points.add_all([source_straight_cp, source_vertical_cp])
  if containing_segment.edges.length() > 1 {
    let center = @core.new_kvector_xy(
      center_x_pos,
      containing_segment.center_control_point_y,
    )
    bend_points.add_vector(center)
  }
  bend_points.add_all([target_vertical_cp, target_straight_cp])
}

///|
fn final_spline_calculate_control_points_conservative(
  edge : LEdge,
  containing_segment : SplineSegment,
  edge_edge_spacing : Double,
  edge_node_spacing : Double,
) -> Unit {
  let start_x_pos = containing_segment.bounding_box.x
  let end_x_pos = containing_segment.bounding_box.x +
    containing_segment.bounding_box.width

  let edge_info = final_spline_require_edge_information(
    containing_segment, edge,
  )
  let y_source_anchor = edge_info.start_y
  let y_target_anchor = edge_info.end_y

  let source_straight_cp = @core.new_kvector_xy(start_x_pos, y_source_anchor)
  let target_straight_cp = @core.new_kvector_xy(end_x_pos, y_target_anchor)

  let mut center_x_pos = start_x_pos
  if !containing_segment.is_west_of_initial_layer {
    center_x_pos += edge_node_spacing
  }
  center_x_pos += containing_segment.x_delta +
    containing_segment.rank.to_double() * edge_edge_spacing

  let source_vertical_cp = @core.new_kvector_xy(center_x_pos, y_source_anchor)
  let target_vertical_cp = @core.new_kvector_xy(center_x_pos, y_target_anchor)

  let bend_points = edge.get_bend_points()
  bend_points.add_all([source_straight_cp, source_vertical_cp])
  if containing_segment.edges.length() > 1 {
    let center = @core.new_kvector_xy(
      center_x_pos,
      containing_segment.center_control_point_y,
    )
    bend_points.add_vector(center)
  }
  bend_points.add_all([target_vertical_cp, target_straight_cp])
}

///|
fn final_spline_node_to_bounding_box(node : LNode) -> @core.ElkRectangle {
  let position = node.get_position()
  let size = node.get_size()
  let margin = node.get_margin()
  @core.new_elk_rectangle_xywh(
    position.x - margin.get_left(),
    position.y - margin.get_top(),
    size.x + margin.get_horizontal(),
    size.y + margin.get_vertical(),
  )
}

///|
fn final_spline_compute_sloppy_center_y(
  edge : LEdge,
  y_source_anchor : Double,
  y_target_anchor : Double,
) -> Double {
  let mut indegree = 0
  let mut outdegree = 0

  if edge.get_source() is Some(_) {
    match edge.get_target() {
      Some(target_port) =>
        match target_port.get_node() {
          Some(target_node) =>
            for port in target_node.get_ports() {
              indegree += port.get_incoming_edges().length()
            }
          None => indegree = 1
        }
      None => indegree = 1
    }
  } else {
    indegree = 1
  }

  if edge.get_target() is Some(_) {
    match edge.get_source() {
      Some(source_port) =>
        match source_port.get_node() {
          Some(source_node) =>
            for port in source_node.get_ports() {
              outdegree += port.get_outgoing_edges().length()
            }
          None => outdegree = 1
        }
      None => outdegree = 1
    }
  } else {
    outdegree = 1
  }

  let degree_diff = @core.signum((outdegree - indegree).to_double())
  (y_target_anchor + y_source_anchor) / 2.0 +
  (y_target_anchor - y_source_anchor) *
  (final_spline_sloppy_center_cp_multiplier * degree_diff.to_double())
}

///|
fn final_spline_calculate_control_points_sloppy(
  edge : LEdge,
  containing_segment : SplineSegment,
) -> Unit {
  let edge_info = final_spline_require_edge_information(
    containing_segment, edge,
  )

  let start_x_pos = containing_segment.bounding_box.x
  let end_x_pos = containing_segment.bounding_box.x +
    containing_segment.bounding_box.width

  let y_source_anchor = edge_info.start_y
  let y_target_anchor = edge_info.end_y
  let edge_points_downwards = y_source_anchor < y_target_anchor

  let source_straight_cp = @core.new_kvector_xy(start_x_pos, y_source_anchor)
  let target_straight_cp = @core.new_kvector_xy(end_x_pos, y_target_anchor)
  let center_x_pos = (start_x_pos + end_x_pos) / 2.0
  let source_vertical_cp = @core.new_kvector_xy(center_x_pos, y_source_anchor)
  let target_vertical_cp = @core.new_kvector_xy(center_x_pos, y_target_anchor)

  let center_y_pos = final_spline_compute_sloppy_center_y(
    edge, y_source_anchor, y_target_anchor,
  )
  let source_port = final_spline_require_segment_source_port(containing_segment)
  let target_port = final_spline_require_segment_target_port(containing_segment)
  let v1 = source_port.get_absolute_anchor()
  let v2 = @core.new_kvector_xy(center_x_pos, center_y_pos)
  let v3 = target_port.get_absolute_anchor()
  let approx = @core.approximate_bezier_segment(2, [v1, v2, v3])
  let approx_center = if approx.is_empty() { v2 } else { approx[0] }

  let mut short_cut_source = false
  match source_port.get_node() {
    Some(source_node) =>
      match source_node.get_layer() {
        Some(source_layer) =>
          if edge_info.normal_source_node {
            let source_id = source_node.get_id()
            let layer_node_count = source_layer.get_nodes().length()
            let need_to_check_source = (
                edge_points_downwards && source_id < layer_node_count - 1
              ) ||
              (!edge_points_downwards && source_id > 0)

            if !need_to_check_source {
              short_cut_source = true
            } else {
              let mut neighbor_index = source_id
              if edge_points_downwards {
                neighbor_index += 1
              } else {
                neighbor_index -= 1
              }

              let neighbor = source_layer.get_nodes()[neighbor_index]
              let box = final_spline_node_to_bounding_box(neighbor)
              short_cut_source = !(@core.intersects_rect_line(
                  box, v1, approx_center,
                ) ||
                @core.contains_rect_line(box, v1, approx_center))
            }
          }
        None => ()
      }
    None => ()
  }

  let mut short_cut_target = false
  match target_port.get_node() {
    Some(target_node) =>
      match target_node.get_layer() {
        Some(target_layer) =>
          if edge_info.normal_target_node {
            let target_id = target_node.get_id()
            let layer_node_count = target_layer.get_nodes().length()
            let need_to_check_target = (edge_points_downwards && target_id > 0) ||
              (!edge_points_downwards && target_id < layer_node_count - 1)

            if !need_to_check_target {
              short_cut_target = true
            } else {
              let mut neighbor_index = target_id
              if edge_points_downwards {
                neighbor_index -= 1
              } else {
                neighbor_index += 1
              }

              let neighbor = target_layer.get_nodes()[neighbor_index]
              let box = final_spline_node_to_bounding_box(neighbor)
              short_cut_target = !(@core.intersects_rect_line(
                  box, approx_center, v3,
                ) ||
                @core.contains_rect_line(box, approx_center, v3))
            }
          }
        None => ()
      }
    None => ()
  }

  let bend_points = edge.get_bend_points()
  if short_cut_source && short_cut_target {
    bend_points.add_vector(v2)
  }
  if !short_cut_source {
    bend_points.add_all([source_straight_cp, source_vertical_cp])
  }
  if !short_cut_target {
    bend_points.add_all([target_vertical_cp, target_straight_cp])
  }
}

///|
fn final_spline_abs_min(d1 : Double, d2 : Double) -> Double {
  if d1.abs() < d2.abs() {
    d1
  } else {
    d2
  }
}

///|
fn final_spline_insert_straightening_control_points(
  all_cps : @core.KVectorChain,
  source_port : LPort,
  target_port : LPort,
) -> Unit {
  if all_cps.size() < 2 {
    return
  }

  let first = all_cps.get(0)
  let second = all_cps.get(1)

  let begin_direction = @core.new_kvector_angle(
    splines_math_port_side_to_direction(source_port.get_side()),
  ).scale(final_spline_node_to_straightening_cp_gap)
  let begin_delta = second.clone().sub(first)
  let straighten_beginning = @core.new_kvector_xy(
    final_spline_abs_min(begin_direction.x, begin_delta.x),
    final_spline_abs_min(begin_direction.y, begin_delta.y),
  )
  ignore(straighten_beginning.add(first))

  ignore(all_cps.vectors.insert(1, straighten_beginning))

  let last_index = all_cps.size() - 1
  let last = all_cps.get(last_index)
  let second_last = all_cps.get(last_index - 1)

  let end_direction = @core.new_kvector_angle(
    splines_math_port_side_to_direction(target_port.get_side()),
  ).scale(final_spline_node_to_straightening_cp_gap)
  let end_delta = second_last.clone().sub(last)
  let straighten_ending = @core.new_kvector_xy(
    final_spline_abs_min(end_direction.x, end_delta.x),
    final_spline_abs_min(end_direction.y, end_delta.y),
  )
  ignore(straighten_ending.add(last))

  ignore(all_cps.vectors.insert(all_cps.size() - 1, straighten_ending))
}

///|
fn final_spline_calculate_bezier_bend_points(
  edge_chain : Array[LEdge],
  surviving_edge : LEdge?,
  spline_routing_mode : SplineRoutingMode,
) -> Unit raise FinalSplineBendpointsCalculatorException {
  if edge_chain.is_empty() {
    return
  }

  let all_control_points = @core.new_kvector_chain()
  let edge = match surviving_edge {
    Some(value) => value
    None => edge_chain[0]
  }

  let source_port = final_spline_require_edge_source(edge)
  if !spline_edge_router_is_qualified_as_starting_node(
      final_spline_require_port_node(source_port),
    ) {
    final_spline_raise_illegal_argument(
      "The target node of the edge must be a normal node or a northSouthPort.",
    )
  }

  all_control_points.add_last_vector(source_port.get_absolute_anchor())
  if final_spline_port_side_in_array(
      source_port.get_side(),
      @core.sides_north_south,
    ) {
    let y = source_port.get_property_double(
      internal_properties_spline_ns_port_y_coord,
    )
    let north_south_cp = @core.new_kvector_xy(
      source_port.get_absolute_anchor().x,
      y,
    )
    all_control_points.add_last_vector(north_south_cp)
  }

  let mut last_control_point : @core.KVector? = None
  let mut add_mid_point = false
  for current_edge in edge_chain {
    let current_bend_points = current_edge.get_bend_points()
    if current_bend_points.is_empty() {
      continue
    }

    if add_mid_point {
      let previous = last_control_point.unwrap()
      let halfway = previous
        .clone()
        .add(current_bend_points.get(0))
        .scale(final_spline_one_half)
      all_control_points.add_last_vector(halfway)
      add_mid_point = false
    } else {
      add_mid_point = true
    }

    last_control_point = Some(
      current_bend_points.get(current_bend_points.size() - 1).clone(),
    )
    all_control_points.add_all(current_bend_points.to_array())
    current_bend_points.clear()
  }

  let target_port = final_spline_require_edge_target(edge)
  if final_spline_port_side_in_array(
      target_port.get_side(),
      @core.sides_north_south,
    ) {
    let y = target_port.get_property_double(
      internal_properties_spline_ns_port_y_coord,
    )
    let north_south_cp = @core.new_kvector_xy(
      target_port.get_absolute_anchor().x,
      y,
    )
    all_control_points.add_last_vector(north_south_cp)
  }
  all_control_points.add_last_vector(target_port.get_absolute_anchor())

  if final_spline_spline_routing_mode_equals(
      spline_routing_mode,
      SplineRoutingMode::Conservative,
    ) {
    final_spline_insert_straightening_control_points(
      all_control_points, source_port, target_port,
    )
  }

  let nub_spline = new_nub_spline(
    true,
    spline_edge_router_spline_dimension,
    all_control_points.to_array(),
  ) catch {
    NubSplineException::IllegalArgumentException(message) =>
      final_spline_raise_illegal_argument(message)
  }
  edge.get_bend_points().add_all(nub_spline.get_control_points().to_array())
}

///|
fn final_spline_segment_node_distance_threshold(node : LNode) -> Double {
  final_spline_require_node_layer(node).get_size().x - node.get_size().x / 2.0
}

///|
fn final_spline_segment_allows_sloppy_routing(
  segment : SplineSegment,
  compaction_strategy : GraphCompactionStrategy,
) -> Bool {
  if final_spline_graph_compaction_strategy_equals(
      compaction_strategy,
      GraphCompactionStrategy::NoneType,
    ) {
    return true
  }

  let start_x_pos = segment.bounding_box.x
  let end_x_pos = segment.bounding_box.x + segment.bounding_box.width

  if segment.initial_segment {
    match segment.source_node {
      Some(source_node) => {
        let threshold = final_spline_segment_node_distance_threshold(
          source_node,
        )
        let node_segment_distance = start_x_pos -
          (source_node.get_position().x + source_node.get_size().x)
        if node_segment_distance > threshold {
          return false
        }
      }
      None => ()
    }
  }

  if segment.last_segment {
    match segment.target_node {
      Some(target_node) => {
        let threshold = final_spline_segment_node_distance_threshold(
          target_node,
        )
        let node_segment_distance = target_node.get_position().x - end_x_pos
        if node_segment_distance > threshold {
          return false
        }
      }
      None => ()
    }
  }

  true
}

///|
fn final_spline_calculate_control_points(
  segment : SplineSegment,
  edge_edge_spacing : Double,
  edge_node_spacing : Double,
  spline_routing_mode : SplineRoutingMode,
  compaction_strategy : GraphCompactionStrategy,
) -> Unit {
  if segment.handled {
    return
  }
  segment.handled = true

  for edge in segment.edges {
    if segment.is_straight && !segment.is_hyper_edge() {
      final_spline_calculate_control_points_straight(segment)
      continue
    }

    let edge_info = final_spline_require_edge_information(segment, edge)
    if edge_info.inverted_left || edge_info.inverted_right {
      final_spline_calculate_control_points_inverted_edge(
        edge, segment, edge_edge_spacing, edge_node_spacing,
      )
      continue
    }

    let sloppy = final_spline_spline_routing_mode_equals(
        spline_routing_mode,
        SplineRoutingMode::Sloppy,
      ) &&
      (edge_info.normal_source_node || edge_info.normal_target_node) &&
      final_spline_segment_allows_sloppy_routing(segment, compaction_strategy) &&
      !segment.is_hyper_edge()

    if sloppy {
      final_spline_calculate_control_points_sloppy(edge, segment)
    } else {
      final_spline_calculate_control_points_conservative(
        edge, segment, edge_edge_spacing, edge_node_spacing,
      )
    }
  }

  if segment.inverse_order {
    for edge in segment.edges {
      let current = edge.get_bend_points()
      let reversed = @core.kvector_chain_reverse(current)
      current.clear()
      current.add_all(reversed.to_array())
    }
  }
}

///|
fn final_spline_bendpoints_calculator_process(
  graph : LGraph,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  ignore(progress_monitor)

  let edge_edge_spacing = graph.get_property_double(
    layered_options_spacing_edge_edge_between_layers,
  )
  let edge_node_spacing = graph.get_property_double(
    layered_options_spacing_edge_node_between_layers,
  )
  let spline_routing_mode = graph.get_property_spline_routing_mode(
    layered_options_edge_routing_splines_mode,
  )
  let compaction_strategy = final_spline_parse_graph_compaction_strategy(
    graph.get_property_string(
      layered_options_compaction_post_compaction_strategy,
    ),
  )

  try {
    final_spline_index_nodes_per_layer(graph)

    let start_edges = final_spline_collect_start_edges(graph)

    for edge in start_edges {
      let spline = edge.get_property_spline_segment_array(
        internal_properties_spline_route_start,
      )
      for segment in spline {
        final_spline_calculate_control_points(
          segment, edge_edge_spacing, edge_node_spacing, spline_routing_mode, compaction_strategy,
        )
      }
      edge.set_property_spline_segment_array(
        internal_properties_spline_route_start,
        [],
      )
    }

    for edge in start_edges {
      let surviving_edge = edge.get_property_l_edge(
        internal_properties_spline_surviving_edge,
      )
      let edge_chain = edge.get_property_l_edge_array(
        internal_properties_spline_edge_chain,
      )
      final_spline_calculate_bezier_bend_points(
        edge_chain, surviving_edge, spline_routing_mode,
      )
      edge.set_property_l_edge_array(internal_properties_spline_edge_chain, [])
    }
  } catch {
    FinalSplineBendpointsCalculatorException::IllegalArgumentException(message) =>
      @core.layout_runtime_report_unsupported_configuration(
        "java.lang.IllegalArgumentException: " + message,
      )
  } noraise {
    _ => ()
  }
}

///|
pub fn new_final_spline_bendpoints_calculator_layout_processor() -> @core.ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  @core.new_layout_processor(final_spline_bendpoints_calculator_process)
}
