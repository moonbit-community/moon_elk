///|
fn radial_first_edge_section(
  edge : ElkEdge,
  create_if_missing : Bool,
) -> ElkEdgeSection? {
  let sections = edge_sections(edge)
  if !sections.is_empty() {
    return Some(sections[0])
  }
  if create_if_missing {
    Some(create_edge_section(edge))
  } else {
    None
  }
}

///|
fn straight_line_edge_router_route_edges(node : ElkNode) -> Unit {
  for edge in node_outgoing_edges(node) {
    let sources = edge_sources(edge)
    if sources.is_empty() ||
      connectable_shape_to_port(Some(sources[0])) is Some(_) {
      continue
    }
    let targets = edge_targets(edge)
    if targets.is_empty() {
      continue
    }
    let target = connectable_shape_to_node(Some(targets[0]))
    let mut source_x = node_x(node) + node_width(node) / 2.0
    let mut source_y = node_y(node) + node_height(node) / 2.0
    let mut target_x = node_x(target) + node_width(target) / 2.0
    let mut target_y = node_y(target) + node_height(target) / 2.0

    let vector = new_kvector_xy(target_x - source_x, target_y - source_y)
    let source_clip = new_kvector_copy(vector)
    ignore(clip_vector(source_clip, node_width(node), node_height(node)))
    vector.x -= source_clip.x
    vector.y -= source_clip.y
    source_x = target_x - vector.x
    source_y = target_y - vector.y

    let target_clip = new_kvector_copy(vector)
    ignore(clip_vector(target_clip, node_width(target), node_height(target)))
    vector.x -= target_clip.x
    vector.y -= target_clip.y
    target_x = source_x + vector.x
    target_y = source_y + vector.y

    match radial_first_edge_section(edge, true) {
      Some(section) => {
        edge_section_set_start(section, source_x, source_y)
        edge_section_set_end(section, target_x, target_y)
      }
      None => ()
    }
    straight_line_edge_router_route_edges(target)
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
  node : ElkNode,
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
pub fn new_radial_straight_line_edge_router_layout_phase() -> ILayoutProcessor[
  RadialLayoutPhases,
  ElkNode,
] {
  new_layout_phase(
    (graph, progress_monitor) => {
      match progress_monitor {
        Some(monitor) => {
          ignore(monitor.begin("Straight Line Edge Routing", 1.0))
          monitor.log_graph("Before")
        }
        None => ()
      }
      match radial_internal_root(graph) {
        Some(root) => new_straight_line_edge_router().route_edges(root)
        None => ()
      }
      match progress_monitor {
        Some(monitor) => monitor.log_graph("After")
        None => ()
      }
    },
    _ => None,
  )
}
