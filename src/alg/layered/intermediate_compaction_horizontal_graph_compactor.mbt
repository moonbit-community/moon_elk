///|
fn horizontal_graph_compactor_graph_compaction_strategy_equals(
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
fn horizontal_graph_compactor_node_type_equals(
  left : NodeType,
  right : NodeType,
) -> Bool {
  match (left, right) {
    (Normal, Normal) => true
    (LongEdge, LongEdge) => true
    (ExternalPort, ExternalPort) => true
    (NorthSouthPort, NorthSouthPort) => true
    (LabelNode, LabelNode) => true
    (BreakingPoint, BreakingPoint) => true
    (Placeholder, Placeholder) => true
    (NonshiftingPlaceholder, NonshiftingPlaceholder) => true
    _ => false
  }
}

///|
fn horizontal_graph_compactor_port_side_is(
  side : @core.PortSide,
  expected : @core.PortSide,
) -> Bool {
  match (side, expected) {
    (SideUndefined, SideUndefined) => true
    (North, North) => true
    (East, East) => true
    (South, South) => true
    (West, West) => true
    _ => false
  }
}

///|
fn horizontal_graph_compactor_parse_graph_compaction_strategy(
  value : String,
) -> GraphCompactionStrategy {
  let normalized = value.trim().to_owned().to_upper()
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
fn horizontal_graph_compactor_parse_post_compaction_constraints(
  value : String,
) -> String {
  value.trim().to_owned().to_upper()
}

///|
fn horizontal_graph_compactor_port_is_input(port : LPort) -> Bool {
  !port.get_incoming_edges().is_empty()
}

///|
fn horizontal_graph_compactor_port_is_output(port : LPort) -> Bool {
  !port.get_outgoing_edges().is_empty()
}

///|
fn horizontal_graph_compactor_edge_list_intersects(
  left : Array[LEdge],
  right : Array[LEdge],
) -> Bool {
  for left_edge in left {
    for right_edge in right {
      if left_edge.get_handle() == right_edge.get_handle() {
        return true
      }
    }
  }
  false
}

///|
fn horizontal_graph_compactor_require_group(
  node : @common.CNode,
) -> @common.CGroup {
  match node.group() {
    Some(group) => group
    None => {
      @core.layout_runtime_report_unsupported_configuration(
        "Compaction node has no group.",
      )
      horizontal_graph_compactor_require_group(node)
    }
  }
}

///|
pub fn horizontal_graph_compactor_register_origin_lnode(
  key : String,
  node : LNode,
) -> Unit {
  horizontal_graph_compactor_lnode_origin_lookup.val[key] = node
}

///|
pub fn horizontal_graph_compactor_register_origin_vertical_segment(
  key : String,
  segment : VerticalSegment,
) -> Unit {
  horizontal_graph_compactor_vertical_segment_origin_lookup.val[key] = segment
}

///|
pub fn horizontal_graph_compactor_clear_origin_lookup() -> Unit {
  horizontal_graph_compactor_lnode_origin_lookup.val = Map([])
  horizontal_graph_compactor_vertical_segment_origin_lookup.val = Map([])
}

///|
pub fn horizontal_graph_compactor_lnode_origin_key(node : LNode) -> String {
  "lnode:" + node.get_handle().to_string()
}

///|
pub fn horizontal_graph_compactor_vertical_segment_origin_key(
  segment : VerticalSegment,
) -> String {
  vertical_segment_origin_key(segment)
}

///|
pub fn horizontal_graph_compactor_get_lnode_or_null(
  c_node : @common.CNode,
) -> LNode? {
  match c_node.origin() {
    Some(origin_key) =>
      match horizontal_graph_compactor_lnode_origin_lookup.val.get(origin_key) {
        Some(node) => Some(node)
        None => None
      }
    None => None
  }
}

///|
pub fn horizontal_graph_compactor_get_vertical_segment_or_null(
  c_node : @common.CNode,
) -> VerticalSegment? {
  match c_node.origin() {
    Some(origin_key) =>
      match
        horizontal_graph_compactor_vertical_segment_origin_lookup.val.get(
          origin_key,
        ) {
        Some(segment) => Some(segment)
        None => None
      }
    None => None
  }
}

///|
pub fn horizontal_graph_compactor_is_vertical_segments_of_same_edge(
  c_node1 : @common.CNode,
  c_node2 : @common.CNode,
) -> Bool {
  match
    (
      horizontal_graph_compactor_get_vertical_segment_or_null(c_node1),
      horizontal_graph_compactor_get_vertical_segment_or_null(c_node2),
    ) {
    (Some(v1), Some(v2)) =>
      horizontal_graph_compactor_edge_list_intersects(
        v1.represented_l_edges,
        v2.represented_l_edges,
      )
    _ => false
  }
}

///|
fn horizontal_graph_compactor_spacings_handler(
  graph : LGraph,
) -> @common.ISpacingsHandler {
  let spacings = new_layered_spacings(graph)

  @common.new_spacings_handler(
    (c_node1, c_node2) => {
      if horizontal_graph_compactor_is_vertical_segments_of_same_edge(
          c_node1, c_node2,
        ) {
        return 0.0
      }

      let node1 = horizontal_graph_compactor_get_lnode_or_null(c_node1)
      let node2 = horizontal_graph_compactor_get_lnode_or_null(c_node2)

      match node1 {
        Some(value) =>
          if horizontal_graph_compactor_node_type_equals(
              value.get_type(),
              ExternalPort,
            ) {
            return 0.0
          }
        None => ()
      }
      match node2 {
        Some(value) =>
          if horizontal_graph_compactor_node_type_equals(
              value.get_type(),
              ExternalPort,
            ) {
            return 0.0
          }
        None => ()
      }

      let node_type1 = match node1 {
        Some(value) => value.get_type()
        None => LongEdge
      }
      let node_type2 = match node2 {
        Some(value) => value.get_type()
        None => LongEdge
      }

      spacings.get_horizontal_spacing_for_node_type(node_type1, node_type2) catch {
        LayeredSpacingsException(message) => {
          @core.layout_runtime_report_unsupported_configuration(message)
          0.0
        }
      }
    },
    (c_node1, c_node2) => {
      if horizontal_graph_compactor_is_vertical_segments_of_same_edge(
          c_node1, c_node2,
        ) {
        return 1.0
      }

      let node1 = horizontal_graph_compactor_get_lnode_or_null(c_node1)
      let node2 = horizontal_graph_compactor_get_lnode_or_null(c_node2)

      let node_type1 = match node1 {
        Some(value) => value.get_type()
        None => LongEdge
      }
      let node_type2 = match node2 {
        Some(value) => value.get_type()
        None => LongEdge
      }

      spacings.get_vertical_spacing_for_node_type(node_type1, node_type2) catch {
        LayeredSpacingsException(message) => {
          @core.layout_runtime_report_unsupported_configuration(message)
          0.0
        }
      }
    },
  )
}

///|
fn horizontal_graph_compactor_process(
  layered_graph : LGraph,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  let strategy = horizontal_graph_compactor_parse_graph_compaction_strategy(
    layered_graph.get_property_string(
      @options.layered_options_compaction_post_compaction_strategy,
    ),
  )
  if horizontal_graph_compactor_graph_compaction_strategy_equals(
      strategy,
      NoneType,
    ) {
    return
  }

  match progress_monitor {
    Some(monitor) => ignore(monitor.begin("Horizontal Compaction", 1.0))
    None => ()
  }

  let transformer = new_lgraph_to_cgraph_transformer()
  let odc = @common.new_one_dimensional_compactor(
    transformer.transform(layered_graph),
  )
  ignore(
    odc.set_spacings_handler(
      horizontal_graph_compactor_spacings_handler(layered_graph),
    ),
  )

  let constraint_mode = horizontal_graph_compactor_parse_post_compaction_constraints(
    layered_graph.get_property_string(
      @options.layered_options_compaction_post_compaction_constraints,
    ),
  )
  if constraint_mode == "SCANLINE" {
    ignore(
      odc.set_constraint_algorithm(
        new_edge_aware_scanline_constraint_calculation(layered_graph),
      ),
    )
  } else {
    ignore(
      odc.set_constraint_algorithm(
        @common.one_dimensional_compactor_quadratic_constraints,
      ),
    )
  }

  match strategy {
    Left => ignore(odc.compact())
    Right => ignore(odc.change_direction(Rightward).compact())
    LeftRightConstraintLocking =>
      ignore(
        odc
        .compact()
        .change_direction(Rightward)
        .set_lock_function(
          Some((node, _dir) => {
            horizontal_graph_compactor_require_group(node).out_degree_real() ==
            0
          }),
        )
        .compact(),
      )
    LeftRightConnectionLocking =>
      ignore(
        odc
        .compact()
        .change_direction(Rightward)
        .set_lock_function(
          Some((node, dir) => {
            match transformer.get_lock(node) {
              Some(lock_value) => lock_value.get(dir)
              None => false
            }
          }),
        )
        .compact(),
      )
    EdgeLength => {
      ignore(
        odc.set_compaction_algorithm(
          horizontal_graph_compactor_network_simplex_compaction,
        ),
      )
      ignore(odc.compact())
    }
    NoneType => ()
  }

  ignore(odc.finish())
  transformer.apply_layout()
  horizontal_graph_compactor_clear_origin_lookup()

  match progress_monitor {
    Some(monitor) => monitor.done()
    None => ()
  }
}

///|
pub fn new_horizontal_graph_compactor_layout_processor() -> @core.ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  @core.new_layout_processor(horizontal_graph_compactor_process)
}

///|
let horizontal_graph_compactor_lnode_origin_lookup : Ref[Map[String, LNode]] = Ref(
  Map([]),
)

///|
let horizontal_graph_compactor_vertical_segment_origin_lookup : Ref[
  Map[String, VerticalSegment],
] = Ref(Map([]))

///|
pub let horizontal_graph_compactor_network_simplex_compaction : @common.ICompactionAlgorithm = network_simplex_compaction
