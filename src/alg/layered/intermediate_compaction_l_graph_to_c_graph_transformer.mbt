///|
priv suberror LGraphToCGraphTransformerException {
  LGraphToCGraphTransformerException(String)
} derive(Show, ToJson)

///|
fn[T] lgraph_to_cgraph_transformer_raise(
  message : String,
) -> T raise LGraphToCGraphTransformerException {
  raise LGraphToCGraphTransformerException(message)
}

///|
fn lgraph_to_cgraph_transformer_node_type_equals(
  left : NodeType,
  right : NodeType,
) -> Bool {
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
fn lgraph_to_cgraph_transformer_port_side_equals(
  left : @core.PortSide,
  right : @core.PortSide,
) -> Bool {
  match (left, right) {
    (@core.PortSide::SideUndefined, @core.PortSide::SideUndefined) => true
    (@core.PortSide::North, @core.PortSide::North) => true
    (@core.PortSide::East, @core.PortSide::East) => true
    (@core.PortSide::South, @core.PortSide::South) => true
    (@core.PortSide::West, @core.PortSide::West) => true
    _ => false
  }
}

///|
fn lgraph_to_cgraph_transformer_parse_edge_routing(
  value : String,
) -> @core.EdgeRouting {
  let normalized = value.trim().to_string().to_upper()
  match normalized {
    "POLYLINE" => @core.EdgeRouting::Polyline
    "SPLINES" => @core.EdgeRouting::Splines
    "ORTHOGONAL" => @core.EdgeRouting::Orthogonal
    _ => @core.EdgeRouting::RoutingUndefined
  }
}

///|
fn lgraph_to_cgraph_transformer_edge_routing_equals(
  left : @core.EdgeRouting,
  right : @core.EdgeRouting,
) -> Bool {
  match (left, right) {
    (@core.EdgeRouting::RoutingUndefined, @core.EdgeRouting::RoutingUndefined) =>
      true
    (@core.EdgeRouting::Polyline, @core.EdgeRouting::Polyline) => true
    (@core.EdgeRouting::Orthogonal, @core.EdgeRouting::Orthogonal) => true
    (@core.EdgeRouting::Splines, @core.EdgeRouting::Splines) => true
    _ => false
  }
}

///|
fn lgraph_to_cgraph_transformer_require_source(
  edge : LEdge,
) -> LPort raise LGraphToCGraphTransformerException {
  match edge.get_source() {
    Some(value) => value
    None => lgraph_to_cgraph_transformer_raise("Edge has no source port.")
  }
}

///|
fn lgraph_to_cgraph_transformer_require_target(
  edge : LEdge,
) -> LPort raise LGraphToCGraphTransformerException {
  match edge.get_target() {
    Some(value) => value
    None => lgraph_to_cgraph_transformer_raise("Edge has no target port.")
  }
}

///|
fn lgraph_to_cgraph_transformer_require_port_node(
  port : LPort,
) -> LNode raise LGraphToCGraphTransformerException {
  match port.get_node() {
    Some(value) => value
    None => lgraph_to_cgraph_transformer_raise("Port has no owner node.")
  }
}

///|
fn lgraph_to_cgraph_transformer_require_cgraph(
  transformer : LGraphToCGraphTransformer,
) -> @common.CGraph raise LGraphToCGraphTransformerException {
  match transformer.c_graph {
    Some(graph) => graph
    None =>
      lgraph_to_cgraph_transformer_raise("Transformer has no @common.CGraph.")
  }
}

///|
fn lgraph_to_cgraph_transformer_require_lgraph(
  transformer : LGraphToCGraphTransformer,
) -> LGraph raise LGraphToCGraphTransformerException {
  match transformer.layered_graph {
    Some(graph) => graph
    None =>
      lgraph_to_cgraph_transformer_raise("Transformer has no layered graph.")
  }
}

///|
fn lgraph_to_cgraph_transformer_lookup_node(
  transformer : LGraphToCGraphTransformer,
  node : LNode,
) -> @common.CNode? {
  transformer.nodes_map.get(node.get_handle())
}

///|
fn lgraph_to_cgraph_transformer_lookup_vertical_segment(
  transformer : LGraphToCGraphTransformer,
  segment : VerticalSegment,
) -> @common.CNode? {
  transformer.vertical_segments_map.get(segment.get_id())
}

///|
fn lgraph_to_cgraph_transformer_sort_vertical_segments(
  vertical_segments : Array[VerticalSegment],
) -> Unit {
  let length = vertical_segments.length()
  for i in 1..<length {
    let current = vertical_segments[i]
    let mut j = i
    while j > 0 && current.compare_to(vertical_segments[j - 1]) < 0 {
      vertical_segments[j] = vertical_segments[j - 1]
      j -= 1
    }
    vertical_segments[j] = current
  }
}

///|
fn lgraph_to_cgraph_transformer_supports_has_edges(
  graph : LGraph,
) -> (Array[@core.Direction], Bool) {
  let mut has_edges = false
  let mut index = 0
  for layer in graph.get_layers() {
    layer.set_id(index)
    index = index + 1
    for node in layer.get_nodes() {
      if !has_edges && !node.get_connected_edges().is_empty() {
        has_edges = true
      }
    }
  }

  let supported = [
    @core.Direction::Undefined,
    @core.Direction::Leftward,
    @core.Direction::Rightward,
  ]
  if !has_edges {
    supported.push(@core.Direction::Upward)
    supported.push(@core.Direction::Downward)
  }
  (supported, has_edges)
}

///|
fn lgraph_to_cgraph_transformer_comment_offset(
  comment : LNode,
  other : LNode,
) -> @core.KVector {
  comment.get_position().clone().sub(other.get_position())
}

///|
fn lgraph_to_cgraph_transformer_require_hitbox_pre_compaction(
  c_node : @common.CNode,
) -> @core.ElkRectangle raise LGraphToCGraphTransformerException {
  match c_node.hitbox_pre_compaction() {
    Some(value) => value
    None => lgraph_to_cgraph_transformer_raise("Missing pre-compaction hitbox.")
  }
}

///|
fn lgraph_to_cgraph_transformer_collect_vertical_segments_orthogonal(
  transformer : LGraphToCGraphTransformer,
) -> Array[VerticalSegment] raise LGraphToCGraphTransformerException {
  let vertical_segments : Array[VerticalSegment] = []
  let layered_graph = lgraph_to_cgraph_transformer_require_lgraph(transformer)

  for layer in layered_graph.get_layers() {
    for node in layer.get_nodes() {
      let c_node = match
        lgraph_to_cgraph_transformer_lookup_node(transformer, node) {
        Some(value) => value
        None => continue
      }

      for edge in node.get_outgoing_edges() {
        let bends = edge.get_bend_points().to_array()
        if bends.is_empty() {
          continue
        }

        let mut first = true
        let mut last_segment : VerticalSegment? = None
        let mut bend1 = bends[0]
        let c_hitbox = c_node.hitbox()
        let source_port = lgraph_to_cgraph_transformer_require_source(edge)

        if lgraph_to_cgraph_transformer_port_side_equals(
            source_port.get_side(),
            @core.PortSide::North,
          ) {
          let vs = new_vertical_segment(
            bend1,
            @core.new_kvector_xy(bend1.x, c_hitbox.y),
            Some(c_node),
            edge,
          )
          vs.ignore_spacing.set_direction(true, @core.Direction::Downward)
          vs.set_a_port(Some(source_port))
          vertical_segments.push(vs)
        }
        if lgraph_to_cgraph_transformer_port_side_equals(
            source_port.get_side(),
            @core.PortSide::South,
          ) {
          let vs = new_vertical_segment(
            bend1,
            @core.new_kvector_xy(bend1.x, c_hitbox.y + c_hitbox.height),
            Some(c_node),
            edge,
          )
          vs.ignore_spacing.set_direction(true, @core.Direction::Upward)
          vs.set_a_port(Some(source_port))
          vertical_segments.push(vs)
        }

        let mut i = 1
        while i < bends.length() {
          let bend2 = bends[i]
          if !@common.compare_fuzzy_eq(bend1.y, bend2.y) {
            let current = new_vertical_segment(bend1, bend2, None, edge)
            vertical_segments.push(current)
            last_segment = Some(current)

            if first {
              first = false
              if bend2.y < c_hitbox.y {
                current.ignore_spacing.set_direction(
                  true,
                  @core.Direction::Downward,
                )
              } else if bend2.y > c_hitbox.y + c_hitbox.height {
                current.ignore_spacing.set_direction(
                  true,
                  @core.Direction::Upward,
                )
              } else {
                current.ignore_spacing.set_direction(
                  true,
                  @core.Direction::Upward,
                )
                current.ignore_spacing.set_direction(
                  true,
                  @core.Direction::Downward,
                )
              }
            }
          }

          if i < bends.length() - 1 {
            bend1 = bend2
          }
          i = i + 1
        }

        match last_segment {
          Some(segment) => {
            let target_node = lgraph_to_cgraph_transformer_require_port_node(
              lgraph_to_cgraph_transformer_require_target(edge),
            )
            match
              lgraph_to_cgraph_transformer_lookup_node(transformer, target_node) {
              Some(target_c_node) => {
                let target_hitbox = target_c_node.hitbox()
                if bend1.y < target_hitbox.y {
                  segment.ignore_spacing.set_direction(
                    true,
                    @core.Direction::Downward,
                  )
                } else if bend1.y > target_hitbox.y + target_hitbox.height {
                  segment.ignore_spacing.set_direction(
                    true,
                    @core.Direction::Upward,
                  )
                } else {
                  segment.ignore_spacing.set_direction(
                    true,
                    @core.Direction::Upward,
                  )
                  segment.ignore_spacing.set_direction(
                    true,
                    @core.Direction::Downward,
                  )
                }
              }
              None => ()
            }
          }
          None => ()
        }
      }

      for edge in node.get_incoming_edges() {
        let bends = edge.get_bend_points().to_array()
        if bends.is_empty() {
          continue
        }

        let bend1 = bends[bends.length() - 1]
        let c_hitbox = c_node.hitbox()
        let target_port = lgraph_to_cgraph_transformer_require_target(edge)

        if lgraph_to_cgraph_transformer_port_side_equals(
            target_port.get_side(),
            @core.PortSide::North,
          ) {
          let vs = new_vertical_segment(
            bend1,
            @core.new_kvector_xy(bend1.x, c_hitbox.y),
            Some(c_node),
            edge,
          )
          vs.ignore_spacing.set_direction(true, @core.Direction::Downward)
          vs.set_a_port(Some(target_port))
          vertical_segments.push(vs)
        }
        if lgraph_to_cgraph_transformer_port_side_equals(
            target_port.get_side(),
            @core.PortSide::South,
          ) {
          let vs = new_vertical_segment(
            bend1,
            @core.new_kvector_xy(bend1.x, c_hitbox.y + c_hitbox.height),
            Some(c_node),
            edge,
          )
          vs.ignore_spacing.set_direction(true, @core.Direction::Upward)
          vs.set_a_port(Some(target_port))
          vertical_segments.push(vs)
        }
      }
    }
  }

  vertical_segments
}

///|
fn lgraph_to_cgraph_transformer_collect_vertical_segments_splines(
  transformer : LGraphToCGraphTransformer,
) -> Array[VerticalSegment] raise LGraphToCGraphTransformerException {
  let vertical_segments : Array[VerticalSegment] = []
  let layered_graph = lgraph_to_cgraph_transformer_require_lgraph(transformer)

  for layer in layered_graph.get_layers() {
    for node in layer.get_nodes() {
      for outgoing in node.get_outgoing_edges() {
        if !outgoing.has_property_spline_segment_array(
            internal_properties_spline_route_start,
          ) {
          continue
        }
        let spline = outgoing.get_property_spline_segment_array(
          internal_properties_spline_route_start,
        )

        let mut last_vs : VerticalSegment? = None
        for segment in spline {
          if segment.is_straight {
            continue
          }
          if segment.edges.is_empty() {
            continue
          }

          let vs = new_vertical_segment(
            segment.bounding_box.get_top_left(),
            segment.bounding_box.get_bottom_right(),
            None,
            segment.edges[0],
          )
          vs.affected_bounding_boxes.push(segment.bounding_box)
          vertical_segments.push(vs)

          match last_vs {
            Some(prev) => prev.constraints.push(vs)
            None => ()
          }
          last_vs = Some(vs)
        }
      }
    }
  }

  vertical_segments
}

///|
fn lgraph_to_cgraph_transformer_vertical_segment_to_cnode(
  transformer : LGraphToCGraphTransformer,
  vertical_segment : VerticalSegment,
) -> Unit raise LGraphToCGraphTransformerException {
  let c_graph = lgraph_to_cgraph_transformer_require_cgraph(transformer)
  let origin_key = horizontal_graph_compactor_vertical_segment_origin_key(
    vertical_segment,
  )

  let c_node = @common.cnode_of()
    .origin(origin_key)
    .node_type("vs")
    .hitbox(@core.new_elk_rectangle_copy(vertical_segment.hitbox))
    .to_string_delegate(_ => vertical_segment.to_string())
    .create(c_graph)

  if !vertical_segment.potential_group_parents.is_empty() {
    let parent = vertical_segment.potential_group_parents[0]
    match parent.group() {
      Some(group) => group.add_cnode(c_node)
      None => ()
    }
  }

  let lock = @common.new_quadruplet()
  transformer.lock_map[origin_key] = lock

  let incoming_ports : Map[Int, Bool] = {}
  let outgoing_ports : Map[Int, Bool] = {}
  for edge in vertical_segment.represented_l_edges {
    let source = lgraph_to_cgraph_transformer_require_source(edge)
    let target = lgraph_to_cgraph_transformer_require_target(edge)
    incoming_ports[source.get_handle()] = true
    outgoing_ports[target.get_handle()] = true
  }
  let difference = incoming_ports.to_array().length() -
    outgoing_ports.to_array().length()
  if difference < 0 {
    lock.set_direction(true, @core.Direction::Leftward)
    lock.set_direction(false, @core.Direction::Rightward)
  } else if difference > 0 {
    lock.set_direction(false, @core.Direction::Leftward)
    lock.set_direction(true, @core.Direction::Rightward)
  }

  for other in vertical_segment.joined {
    transformer.vertical_segments_map[other.get_id()] = c_node
  }
  transformer.vertical_segments_map[vertical_segment.get_id()] = c_node
  horizontal_graph_compactor_register_origin_vertical_segment(
    origin_key, vertical_segment,
  )
}

///|
fn lgraph_to_cgraph_transformer_merge_vertical_segments(
  transformer : LGraphToCGraphTransformer,
  vertical_segments : Array[VerticalSegment],
) -> Unit raise LGraphToCGraphTransformerException {
  if vertical_segments.is_empty() {
    return
  }

  lgraph_to_cgraph_transformer_sort_vertical_segments(vertical_segments)

  let mut survivor = vertical_segments[0]
  let mut index = 1
  while index < vertical_segments.length() {
    let next = vertical_segments[index]
    if survivor.intersects(next) {
      survivor = survivor.join_with(next)
    } else {
      lgraph_to_cgraph_transformer_vertical_segment_to_cnode(
        transformer, survivor,
      )
      survivor = next
    }
    index = index + 1
  }

  lgraph_to_cgraph_transformer_vertical_segment_to_cnode(transformer, survivor)
}

///|
fn lgraph_to_cgraph_transformer_apply_comment_positions(
  transformer : LGraphToCGraphTransformer,
) -> Unit {
  for entry in transformer.comment_offsets {
    let (comment, other, offset) = entry
    ignore(
      comment
      .get_position()
      .reset()
      .add(other.get_position().clone().add(offset)),
    )
  }
}

///|
fn lgraph_to_cgraph_transformer_lookup_cnode_for_spline_endpoint(
  transformer : LGraphToCGraphTransformer,
  node : LNode?,
) -> @common.CNode? {
  match node {
    Some(value) => transformer.nodes_map.get(value.get_handle())
    None => None
  }
}

///|
fn lgraph_to_cgraph_transformer_first_non_straight_segment(
  spline : Array[SplineSegment],
  start_index : Int,
) -> (Int, SplineSegment)? {
  if start_index < 0 || start_index >= spline.length() {
    return None
  }
  for i in start_index..<spline.length() {
    let segment = spline[i]
    if i == spline.length() - 1 || !segment.is_straight {
      return Some((i, segment))
    }
  }
  None
}

///|
fn lgraph_to_cgraph_transformer_adjust_control_points_between_segments(
  transformer : LGraphToCGraphTransformer,
  left : SplineSegment,
  right : SplineSegment,
  left_idx : Int,
  right_idx : Int,
  spline : Array[SplineSegment],
) -> Unit {
  let mut start_x = left.bounding_box.x + left.bounding_box.width
  let mut idx1 = left_idx
  if left.initial_segment && left.is_straight {
    match
      lgraph_to_cgraph_transformer_lookup_cnode_for_spline_endpoint(
        transformer,
        left.source_node,
      ) {
      Some(node) => {
        let hitbox = node.hitbox()
        start_x = hitbox.x + hitbox.width
        idx1 = idx1 - 1
      }
      None => ()
    }
  }

  let mut end_x = right.bounding_box.x
  let mut idx2 = right_idx
  if right.last_segment && right.is_straight {
    match
      lgraph_to_cgraph_transformer_lookup_cnode_for_spline_endpoint(
        transformer,
        right.target_node,
      ) {
      Some(node) => {
        end_x = node.hitbox().x
        idx2 = idx2 + 1
      }
      None => ()
    }
  }

  let strip = end_x - start_x
  let chunks = @cmp.maximum(2, idx2 - idx1)
  let chunk = strip / chunks.to_double()

  let mut new_pos = start_x + chunk
  for k in idx1..<idx2 {
    let adjust = spline[k]
    let width = adjust.bounding_box.width
    adjust.bounding_box.x = new_pos - width / 2.0
    new_pos = new_pos + chunk
  }
}

///|
fn lgraph_to_cgraph_transformer_adjust_spline_control_points(
  transformer : LGraphToCGraphTransformer,
  spline : Array[SplineSegment],
) -> Unit {
  if spline.is_empty() {
    return
  }

  let mut last_seg = spline[0]
  if spline.length() == 1 {
    lgraph_to_cgraph_transformer_adjust_control_points_between_segments(
      transformer, last_seg, last_seg, 1, 0, spline,
    )
    return
  }

  let mut i = 1
  while i < spline.length() {
    if last_seg.initial_segment || !last_seg.is_straight {
      match lgraph_to_cgraph_transformer_first_non_straight_segment(spline, i) {
        Some((j, next_seg)) => {
          lgraph_to_cgraph_transformer_adjust_control_points_between_segments(
            transformer, last_seg, next_seg, i, j, spline,
          )
          i = j + 1
          last_seg = next_seg
        }
        None => i = i + 1
      }
    } else {
      i = i + 1
    }
  }
}

///|
fn lgraph_to_cgraph_transformer_apply_external_port_positions(
  transformer : LGraphToCGraphTransformer,
  top_left : @core.KVector,
  bottom_right : @core.KVector,
) -> Unit raise LGraphToCGraphTransformerException {
  let c_graph = lgraph_to_cgraph_transformer_require_cgraph(transformer)
  for c_node in c_graph.c_nodes {
    let l_node = match horizontal_graph_compactor_get_lnode_or_null(c_node) {
      Some(node) => node
      None => continue
    }
    if !lgraph_to_cgraph_transformer_node_type_equals(
        l_node.get_type(),
        NodeType::ExternalPort,
      ) {
      continue
    }
    match l_node.get_property_port_side(internal_properties_ext_port_side) {
      @core.PortSide::West => l_node.get_position().x = top_left.x
      @core.PortSide::East =>
        l_node.get_position().x = bottom_right.x -
          (l_node.get_size().x + l_node.get_margin().right)
      @core.PortSide::North => l_node.get_position().y = top_left.y
      @core.PortSide::South =>
        l_node.get_position().y = bottom_right.y -
          (l_node.get_size().y + l_node.get_margin().bottom)
      @core.PortSide::SideUndefined => ()
    }
  }
}

///|
fn lgraph_to_cgraph_transformer_cleanup(
  transformer : LGraphToCGraphTransformer,
) -> Unit {
  transformer.nodes_map = {}
  transformer.comment_offsets.clear()
  transformer.vertical_segments_map = {}
  transformer.lock_map = {}
  horizontal_graph_compactor_clear_origin_lookup()

  match transformer.c_graph {
    Some(graph) => {
      graph.c_groups.clear()
      graph.c_nodes.clear()
    }
    None => ()
  }

  transformer.c_graph = None
  transformer.layered_graph = None
}

///|
pub struct LGraphToCGraphTransformer {
  mut c_graph : @common.CGraph?
  mut layered_graph : LGraph?
  mut edge_routing : @core.EdgeRouting
  comment_offsets : Array[(LNode, LNode, @core.KVector)]
  mut nodes_map : Map[Int, @common.CNode]
  mut vertical_segments_map : Map[Int, @common.CNode]
  mut lock_map : Map[String, @common.Quadruplet]
}

///|
pub fn new_lgraph_to_cgraph_transformer() -> LGraphToCGraphTransformer {
  {
    c_graph: None,
    layered_graph: None,
    edge_routing: @core.EdgeRouting::RoutingUndefined,
    comment_offsets: [],
    nodes_map: {},
    vertical_segments_map: {},
    lock_map: {},
  }
}

///|
pub fn LGraphToCGraphTransformer::get_lock_map(
  self : LGraphToCGraphTransformer,
) -> Map[String, @common.Quadruplet] {
  self.lock_map
}

///|
pub fn LGraphToCGraphTransformer::get_lock(
  self : LGraphToCGraphTransformer,
  node : @common.CNode,
) -> @common.Quadruplet? {
  match node.origin() {
    Some(origin_key) => self.lock_map.get(origin_key)
    None => None
  }
}

///|
fn LGraphToCGraphTransformer::init(
  self : LGraphToCGraphTransformer,
) -> Unit raise LGraphToCGraphTransformerException {
  let layered_graph = lgraph_to_cgraph_transformer_require_lgraph(self)
  let (supported_directions, _has_edges) = lgraph_to_cgraph_transformer_supports_has_edges(
    layered_graph,
  )

  self.c_graph = Some(@common.new_cgraph(supported_directions))
  self.nodes_map = {}
  self.comment_offsets.clear()
  self.lock_map = {}
  self.vertical_segments_map = {}
  horizontal_graph_compactor_clear_origin_lookup()
}

///|
fn LGraphToCGraphTransformer::transform_nodes(
  self : LGraphToCGraphTransformer,
) -> Unit raise LGraphToCGraphTransformerException {
  let layered_graph = lgraph_to_cgraph_transformer_require_lgraph(self)
  let c_graph = lgraph_to_cgraph_transformer_require_cgraph(self)

  for layer in layered_graph.get_layers() {
    for node in layer.get_nodes() {
      if node.get_property_bool(layered_options_comment_box) {
        let connected_edges = node.get_connected_edges()
        if !connected_edges.is_empty() {
          let edge = connected_edges[0]
          let mut other = lgraph_to_cgraph_transformer_require_port_node(
            lgraph_to_cgraph_transformer_require_source(edge),
          )
          if other.get_handle() == node.get_handle() {
            other = lgraph_to_cgraph_transformer_require_port_node(
              lgraph_to_cgraph_transformer_require_target(edge),
            )
          }
          self.comment_offsets.push(
            (
              node,
              other,
              lgraph_to_cgraph_transformer_comment_offset(node, other),
            ),
          )
          continue
        }
      }

      let position = node.get_position()
      let margin = node.get_margin()
      let size = node.get_size()
      let hitbox = @core.new_elk_rectangle_xywh(
        position.x - margin.left,
        position.y - margin.top,
        size.x + margin.left + margin.right,
        size.y + margin.top + margin.bottom,
      )

      let origin_key = horizontal_graph_compactor_lnode_origin_key(node)
      let c_node = @common.cnode_of()
        .origin(origin_key)
        .hitbox(hitbox)
        .to_string_delegate(_ => node.to_string())
        .create(c_graph)
      ignore(@common.cgroup_of().nodes([c_node]).master(c_node).create(c_graph))

      let node_lock = @common.new_quadruplet()
      self.lock_map[origin_key] = node_lock

      let difference = node.get_incoming_edges().length() -
        node.get_outgoing_edges().length()
      if difference < 0 {
        node_lock.set_direction(true, @core.Direction::Leftward)
      } else if difference > 0 {
        node_lock.set_direction(true, @core.Direction::Rightward)
      }

      if lgraph_to_cgraph_transformer_node_type_equals(
          node.get_type(),
          NodeType::ExternalPort,
        ) {
        node_lock.set(false, false, false, false)
      }

      self.nodes_map[node.get_handle()] = c_node
      horizontal_graph_compactor_register_origin_lnode(origin_key, node)
    }
  }
}

///|
fn LGraphToCGraphTransformer::transform_edges(
  self : LGraphToCGraphTransformer,
) -> Unit raise LGraphToCGraphTransformerException {
  let mut vertical_segments : Array[VerticalSegment] = []
  match self.edge_routing {
    @core.EdgeRouting::Orthogonal =>
      vertical_segments = lgraph_to_cgraph_transformer_collect_vertical_segments_orthogonal(
        self,
      )
    @core.EdgeRouting::Splines =>
      vertical_segments = lgraph_to_cgraph_transformer_collect_vertical_segments_splines(
        self,
      )
    _ =>
      lgraph_to_cgraph_transformer_raise(
        "Compaction not supported for " +
        @core.edge_routing_to_string(self.edge_routing) +
        " edges.",
      )
  }

  lgraph_to_cgraph_transformer_merge_vertical_segments(self, vertical_segments)

  let c_graph = lgraph_to_cgraph_transformer_require_cgraph(self)
  for segment in vertical_segments {
    let segment_node = match
      lgraph_to_cgraph_transformer_lookup_vertical_segment(self, segment) {
      Some(value) => value
      None => continue
    }
    for other in segment.constraints {
      match lgraph_to_cgraph_transformer_lookup_vertical_segment(self, other) {
        Some(other_node) =>
          c_graph.add_predefined_horizontal_constraint(segment_node, other_node)
        None => ()
      }
    }
  }
}

///|
pub fn LGraphToCGraphTransformer::transform(
  self : LGraphToCGraphTransformer,
  input_graph : LGraph,
) -> @common.CGraph {
  self.layered_graph = Some(input_graph)
  self.edge_routing = lgraph_to_cgraph_transformer_parse_edge_routing(
    input_graph.get_property_string(@core.edge_routing),
  )

  try {
    self.init()
    self.transform_nodes()
    self.transform_edges()
    lgraph_to_cgraph_transformer_require_cgraph(self)
  } catch {
    LGraphToCGraphTransformerException(message) => {
      @core.layout_runtime_report_unsupported_configuration(
        "java.lang.IllegalStateException: " + message,
      )
      match self.c_graph {
        Some(graph) => graph
        None =>
          @common.new_cgraph([
            @core.Direction::Undefined,
            @core.Direction::Leftward,
            @core.Direction::Rightward,
          ])
      }
    }
  } noraise {
    result => result
  }
}

///|
pub fn LGraphToCGraphTransformer::apply_layout(
  self : LGraphToCGraphTransformer,
) -> Unit {
  try {
    let c_graph = lgraph_to_cgraph_transformer_require_cgraph(self)
    let layered_graph = lgraph_to_cgraph_transformer_require_lgraph(self)

    for c_node in c_graph.c_nodes {
      match horizontal_graph_compactor_get_lnode_or_null(c_node) {
        Some(node) => {
          let hitbox = c_node.hitbox()
          node.get_position().x = hitbox.x + node.get_margin().left
        }
        None => ()
      }
    }

    lgraph_to_cgraph_transformer_apply_comment_positions(self)

    for c_node in c_graph.c_nodes {
      match horizontal_graph_compactor_get_vertical_segment_or_null(c_node) {
        Some(segment) => {
          let hitbox = c_node.hitbox()
          let original = lgraph_to_cgraph_transformer_require_hitbox_pre_compaction(
            c_node,
          )
          let delta_x = hitbox.x - original.x
          for bend in segment.affected_bends {
            bend.x = bend.x + delta_x
          }
          for box in segment.affected_bounding_boxes {
            box.x = box.x + delta_x
          }
          ignore(segment.junction_points.offset_xy(delta_x, 0.0))
        }
        None => ()
      }
    }

    if lgraph_to_cgraph_transformer_edge_routing_equals(
        self.edge_routing,
        @core.EdgeRouting::Splines,
      ) {
      for layer in layered_graph.get_layers() {
        for node in layer.get_nodes() {
          let c_node = match self.nodes_map.get(node.get_handle()) {
            Some(value) => value
            None => continue
          }
          let original = lgraph_to_cgraph_transformer_require_hitbox_pre_compaction(
            c_node,
          )
          let delta_x = c_node.hitbox().x - original.x

          for edge in node.get_outgoing_edges() {
            if edge.is_self_loop() {
              ignore(edge.get_bend_points().offset_xy(delta_x, 0.0))
            }
            if edge.has_property_spline_segment_array(
                internal_properties_spline_route_start,
              ) {
              let spline = edge.get_property_spline_segment_array(
                internal_properties_spline_route_start,
              )
              if !spline.is_empty() {
                lgraph_to_cgraph_transformer_adjust_spline_control_points(
                  self, spline,
                )
              }
            }
          }
        }
      }
    }

    for layer in layered_graph.get_layers() {
      for node in layer.get_nodes() {
        let c_node = match self.nodes_map.get(node.get_handle()) {
          Some(value) => value
          None => continue
        }
        let original = lgraph_to_cgraph_transformer_require_hitbox_pre_compaction(
          c_node,
        )
        let delta_x = c_node.hitbox().x - original.x
        for edge in node.get_outgoing_edges() {
          if edge.is_self_loop() {
            for label in edge.get_labels() {
              label.get_position().x = label.get_position().x + delta_x
            }
          }
        }
      }
    }

    let top_left = @core.new_kvector_xy(@double.infinity, @double.infinity)
    let bottom_right = @core.new_kvector_xy(
      -@double.infinity,
      -@double.infinity,
    )
    for c_node in c_graph.c_nodes {
      let hitbox = c_node.hitbox()
      top_left.x = @cmp.minimum(top_left.x, hitbox.x)
      top_left.y = @cmp.minimum(top_left.y, hitbox.y)
      bottom_right.x = @cmp.maximum(bottom_right.x, hitbox.x + hitbox.width)
      bottom_right.y = @cmp.maximum(bottom_right.y, hitbox.y + hitbox.height)
    }

    if top_left.x == @double.infinity {
      ignore(layered_graph.get_offset().reset())
      ignore(layered_graph.get_size().reset())
      lgraph_to_cgraph_transformer_cleanup(self)
      return
    }

    ignore(layered_graph.get_offset().reset().add(top_left.clone().negate()))
    ignore(
      layered_graph.get_size().reset().add(bottom_right.clone().sub(top_left)),
    )

    lgraph_to_cgraph_transformer_apply_external_port_positions(
      self, top_left, bottom_right,
    )
    lgraph_to_cgraph_transformer_cleanup(self)
  } catch {
    LGraphToCGraphTransformerException(message) => {
      @core.layout_runtime_report_unsupported_configuration(
        "java.lang.IllegalStateException: " + message,
      )
      lgraph_to_cgraph_transformer_cleanup(self)
    }
  } noraise {
    _ => ()
  }
}
