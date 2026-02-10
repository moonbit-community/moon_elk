///|
pub struct Mrtree {
  marker : Int
}

///|
pub fn new_mrtree() -> Mrtree {
  { marker: 0 }
}

///|
fn mrtree_roots(graph : MrtreeGraph) -> Array[MrtreeNode] {
  let roots = []
  for node in mrtree_graph_nodes(graph) {
    if mrtree_node_incoming_edges(node).is_empty() {
      roots.push(node)
    }
  }
  if roots.is_empty() && !mrtree_graph_nodes(graph).is_empty() {
    roots.push(mrtree_graph_nodes(graph)[0])
  }
  roots
}

///|
fn mrtree_build_levels(graph : MrtreeGraph) -> Array[Array[MrtreeNode]] {
  let levels = []
  let roots = mrtree_roots(graph)
  let queued_nodes = []
  let queued_levels = []
  for root in roots {
    queued_nodes.push(root)
    queued_levels.push(0)
  }
  let seen = {}
  let mut head = 0
  while head < queued_nodes.length() {
    let node = queued_nodes[head]
    let level = queued_levels[head]
    head += 1
    if seen.contains(node) {
      continue
    }
    seen[node] = true
    while levels.length() <= level {
      levels.push([])
    }
    levels[level].push(node)
    for edge in mrtree_node_outgoing_edges(node) {
      queued_nodes.push(mrtree_edge_target(edge))
      queued_levels.push(level + 1)
    }
  }
  levels
}

///|
fn mrtree_layout_levels(graph : MrtreeGraph) -> Unit {
  let levels = mrtree_build_levels(graph)
  let spacing = mrtree_graph_spacing_node_node(graph)
  let level_widths = []
  let mut level = 0
  while level < levels.length() {
    let nodes_at_level = levels[level]
    let mut width = 0.0
    for node in nodes_at_level {
      let node_width_value = mrtree_node_size(node).x
      if node_width_value > width {
        width = node_width_value
      }
    }
    level_widths.push(width)
    level += 1
  }

  let mut current_x = 0.0
  level = 0
  while level < levels.length() {
    let nodes_at_level = levels[level]
    let mut current_y = 0.0
    for node in nodes_at_level {
      let position = mrtree_node_position(node)
      let size = mrtree_node_size(node)
      position.x = current_x
      position.y = current_y
      current_y += size.y + spacing
    }
    current_x += level_widths[level] + spacing
    level += 1
  }
  mrtree_process_graph_bounds(graph)
}

///|
pub fn Mrtree::do_layout(
  self : Mrtree,
  graph : MrtreeGraph,
  progress_monitor : IElkProgressMonitor,
) -> MrtreeGraph {
  ignore(self)
  ignore(progress_monitor.begin("Tree layout", 1.0))
  mrtree_layout_levels(graph)
  progress_monitor.done()
  graph
}
