///|
fn horizontal_graph_compactor_graph_compaction_strategy_equals(
  left : @options.GraphCompactionStrategy,
  right : @options.GraphCompactionStrategy,
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
  left : @runtime.NodeType,
  right : @runtime.NodeType,
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
) -> @options.GraphCompactionStrategy {
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
fn horizontal_graph_compactor_port_is_input(port : @runtime.LPort) -> Bool {
  !port.get_incoming_edges().is_empty()
}

///|
fn horizontal_graph_compactor_port_is_output(port : @runtime.LPort) -> Bool {
  !port.get_outgoing_edges().is_empty()
}

///|
fn horizontal_graph_compactor_edge_list_intersects(
  left : Array[@runtime.LEdge],
  right : Array[@runtime.LEdge],
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
  node : @compaction.CNode,
) -> @compaction.CGroup raise {
  match node.group() {
    Some(group) => group
    None => {
      @core.layout_runtime_raise_unsupported_configuration(
        "Compaction node has no group.",
      )
      horizontal_graph_compactor_require_group(node)
    }
  }
}

///|
priv struct HorizontalGraphCompactorOriginLookup {
  lnodes : Map[String, @runtime.LNode]
  vertical_segments : Map[String, VerticalSegment]
}

///|
fn new_horizontal_graph_compactor_origin_lookup() -> HorizontalGraphCompactorOriginLookup {
  { lnodes: Map([]), vertical_segments: Map([]) }
}

///|
fn HorizontalGraphCompactorOriginLookup::register_lnode(
  self : HorizontalGraphCompactorOriginLookup,
  key : String,
  node : @runtime.LNode,
) -> Unit {
  self.lnodes[key] = node
}

///|
fn HorizontalGraphCompactorOriginLookup::register_vertical_segment(
  self : HorizontalGraphCompactorOriginLookup,
  key : String,
  segment : VerticalSegment,
) -> Unit {
  self.vertical_segments[key] = segment
}

///|
fn HorizontalGraphCompactorOriginLookup::clear(
  self : HorizontalGraphCompactorOriginLookup,
) -> Unit {
  self.lnodes.clear()
  self.vertical_segments.clear()
}

///|
fn horizontal_graph_compactor_lnode_origin_key(node : @runtime.LNode) -> String {
  "lnode:" + node.get_handle().to_string()
}

///|
fn horizontal_graph_compactor_vertical_segment_origin_key(
  segment : VerticalSegment,
) -> String {
  vertical_segment_origin_key(segment)
}

///|
fn HorizontalGraphCompactorOriginLookup::get_lnode_or_null(
  self : HorizontalGraphCompactorOriginLookup,
  c_node : @compaction.CNode,
) -> @runtime.LNode? {
  match c_node.origin() {
    Some(origin_key) => self.lnodes.get(origin_key)
    None => None
  }
}

///|
fn HorizontalGraphCompactorOriginLookup::get_vertical_segment_or_null(
  self : HorizontalGraphCompactorOriginLookup,
  c_node : @compaction.CNode,
) -> VerticalSegment? {
  match c_node.origin() {
    Some(origin_key) => self.vertical_segments.get(origin_key)
    None => None
  }
}

///|
fn HorizontalGraphCompactorOriginLookup::is_vertical_segments_of_same_edge(
  self : HorizontalGraphCompactorOriginLookup,
  c_node1 : @compaction.CNode,
  c_node2 : @compaction.CNode,
) -> Bool {
  match
    (
      self.get_vertical_segment_or_null(c_node1),
      self.get_vertical_segment_or_null(c_node2),
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
  graph : @runtime.LGraph,
  origin_lookup : HorizontalGraphCompactorOriginLookup,
) -> @compaction.ISpacingsHandler {
  let spacings = @runtime.new_layered_spacings(graph)

  @compaction.new_spacings_handler(
    fn(c_node1, c_node2) raise {
      if origin_lookup.is_vertical_segments_of_same_edge(c_node1, c_node2) {
        return 0.0
      }

      let node1 = origin_lookup.get_lnode_or_null(c_node1)
      let node2 = origin_lookup.get_lnode_or_null(c_node2)

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
          @core.layout_runtime_raise_unsupported_configuration(message)
          0.0
        }
      }
    },
    fn(c_node1, c_node2) raise {
      if origin_lookup.is_vertical_segments_of_same_edge(c_node1, c_node2) {
        return 1.0
      }

      let node1 = origin_lookup.get_lnode_or_null(c_node1)
      let node2 = origin_lookup.get_lnode_or_null(c_node2)

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
          @core.layout_runtime_raise_unsupported_configuration(message)
          0.0
        }
      }
    },
  )
}

///|
fn horizontal_graph_compactor_process(
  layered_graph : @runtime.LGraph,
  progress_monitor : @core.IElkProgressMonitor?,
  state : @runtime.LayeredRunState,
) -> Unit raise {
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

  let transformer = new_lgraph_to_cgraph_transformer(state)
  let origin_lookup = transformer.get_origin_lookup()
  let odc = @compaction.new_one_dimensional_compactor(
    transformer.transform(layered_graph),
  )
  ignore(
    odc.set_spacings_handler(
      horizontal_graph_compactor_spacings_handler(layered_graph, origin_lookup),
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
        new_edge_aware_scanline_constraint_calculation(
          layered_graph, origin_lookup,
        ),
      ),
    )
  } else {
    ignore(
      odc.set_constraint_algorithm(
        @compaction.one_dimensional_compactor_quadratic_constraints,
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
        odc.set_compaction_algorithm(compactor => {
          network_simplex_compaction(origin_lookup, compactor)
        }),
      )
      ignore(odc.compact())
    }
    NoneType => ()
  }

  ignore(odc.finish())
  transformer.apply_layout()

  match progress_monitor {
    Some(monitor) => monitor.done()
    None => ()
  }
}

///|
pub fn new_horizontal_graph_compactor_layout_processor(
  state? : @runtime.LayeredRunState = @runtime.new_layered_run_state(),
) -> @core.TypedLayoutProcessor[@runtime.LGraph] {
  @core.new_layout_processor((graph, monitor) => {
    horizontal_graph_compactor_process(graph, monitor, state)
  })
}
