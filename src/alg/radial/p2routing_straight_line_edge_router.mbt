///|
fn radial_first_edge_section(
  edge : @graph.ElkEdge,
  create_if_missing : Bool,
) -> @graph.ElkEdgeSection? {
  let sections = @graph.edge_sections(edge)
  if !sections.is_empty() {
    return Some(sections[0])
  }
  if create_if_missing {
    Some(@graph.create_edge_section(edge))
  } else {
    None
  }
}

///|
fn radial_all_outgoing_edges(node : @graph.ElkNode) -> Array[@graph.ElkEdge] {
  let outgoing = []
  let seen : Map[@graph.ElkEdge, Bool] = {}

  for edge in @graph.node_outgoing_edges(node) {
    if !seen.contains(edge) {
      seen[edge] = true
      outgoing.push(edge)
    }
  }

  for port in @graph.node_ports(node) {
    for edge in @graph.port_outgoing_edges(port) {
      if !seen.contains(edge) {
        seen[edge] = true
        outgoing.push(edge)
      }
    }
  }

  outgoing
}

///|
fn straight_line_edge_router_route_edges(node : @graph.ElkNode) -> Unit {
  for edge in radial_all_outgoing_edges(node) {
    let source = @graph.edge_sources(edge)[0]
    if source is PortShape(_) {
      continue
    }
    let target = @graph.connectable_shape_to_node(
      Some(@graph.edge_targets(edge)[0]),
    )
    if @graph.node_parent(node) == @graph.node_parent(target) {
      let mut source_x = @graph.node_x(node) + @graph.node_width(node) / 2.0
      let mut source_y = @graph.node_y(node) + @graph.node_height(node) / 2.0

      let mut target_x = @graph.node_x(target) + @graph.node_width(target) / 2.0
      let mut target_y = @graph.node_y(target) +
        @graph.node_height(target) / 2.0

      let vector = @core.new_kvector_xy(
        target_x - source_x,
        target_y - source_y,
      )
      let source_clip = @core.new_kvector_copy(vector)
      ignore(
        @core.clip_vector(
          source_clip,
          @graph.node_width(node),
          @graph.node_height(node),
        ),
      )
      vector.x -= source_clip.x
      vector.y -= source_clip.y

      source_x = target_x - vector.x
      source_y = target_y - vector.y

      let target_clip = @core.new_kvector_copy(vector)
      ignore(
        @core.clip_vector(
          target_clip,
          @graph.node_width(target),
          @graph.node_height(target),
        ),
      )
      vector.x -= target_clip.x
      vector.y -= target_clip.y

      target_x = source_x + vector.x
      target_y = source_y + vector.y

      match radial_first_edge_section(edge, true) {
        Some(section) => {
          @graph.edge_section_set_start(section, source_x, source_y)
          @graph.edge_section_set_end(section, target_x, target_y)
        }
        None => ()
      }
      straight_line_edge_router_route_edges(target)
    }
  }
}

///|
pub struct StraightLineEdgeRouter {
  edge_router : IRadialEdgeRouter
}

///|
pub fn new_straight_line_edge_router() -> StraightLineEdgeRouter {
  {
    edge_router: new_i_radial_edge_router(straight_line_edge_router_route_edges),
  }
}

///|
pub fn StraightLineEdgeRouter::route_edges(
  self : StraightLineEdgeRouter,
  node : @graph.ElkNode,
) -> Unit {
  self.edge_router.route_edges(node)
}

///|
pub fn StraightLineEdgeRouter::as_i_radial_edge_router(
  self : StraightLineEdgeRouter,
) -> IRadialEdgeRouter {
  self.edge_router
}

///|
pub fn new_radial_straight_line_edge_router_layout_phase() -> @core.ILayoutProcessor[
  RadialLayoutPhases,
  @graph.ElkNode,
] {
  @core.new_layout_phase(
    (graph, progress_monitor) => {
      match progress_monitor {
        Some(monitor) => {
          ignore(monitor.begin("Straight Line Edge Routing", 1.0))
          monitor.log_graph("Before")
        }
        None => ()
      }
      let root = match radial_internal_root(graph) {
        Some(root_node) => root_node
        None => abort("radial root node is missing")
      }
      new_straight_line_edge_router().route_edges(root)
      match progress_monitor {
        Some(monitor) => monitor.log_graph("After")
        None => ()
      }
    },
    _ => None,
  )
}
