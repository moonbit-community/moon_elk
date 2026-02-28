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
pub fn mrtree_layout_levels(graph : MrtreeGraph) -> Unit {
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
fn mrtree_update_modules(
  graph : MrtreeGraph,
) -> Array[@core.ILayoutProcessor[MrtreeTreeLayoutPhases, MrtreeGraph]] {
  let algorithm_assembler = @core.algorithm_assembler_create(
    mrtree_tree_layout_phase_descriptor,
  )
  ignore(algorithm_assembler.reset())
  ignore(
    algorithm_assembler.set_phase(
      MrtreeTreeLayoutPhases::P1Treeification,
      mrtree_tree_layout_phase_factory(MrtreeTreeLayoutPhases::P1Treeification),
    ),
  )
  ignore(
    algorithm_assembler.set_phase(
      MrtreeTreeLayoutPhases::P2NodeOrdering,
      mrtree_tree_layout_phase_factory(MrtreeTreeLayoutPhases::P2NodeOrdering),
    ),
  )
  ignore(
    algorithm_assembler.set_phase(
      MrtreeTreeLayoutPhases::P3NodePlacement,
      mrtree_tree_layout_phase_factory(MrtreeTreeLayoutPhases::P3NodePlacement),
    ),
  )
  ignore(
    algorithm_assembler.set_phase(
      MrtreeTreeLayoutPhases::P4EdgeRouting,
      mrtree_tree_layout_phase_factory(MrtreeTreeLayoutPhases::P4EdgeRouting),
    ),
  )
  algorithm_assembler.build(graph)
}

///|
fn mrtree_layout(
  graph : MrtreeGraph,
  algorithm : Array[@core.ILayoutProcessor[MrtreeTreeLayoutPhases, MrtreeGraph]],
  monitor_opt : @core.IElkProgressMonitor?,
) -> Unit {
  let monitor = match monitor_opt {
    Some(existing) => existing
    None => @core.new_basic_progress_monitor()
  }
  ignore(monitor.begin("Layout", algorithm.length().to_double()))
  for processor in algorithm {
    if monitor.is_canceled() {
      return
    }
    processor.process(graph, monitor.sub_task(1.0))
  }
  monitor.done()
}

///|
pub fn Mrtree::do_layout(
  self : Mrtree,
  graph : MrtreeGraph,
  progress_monitor : @core.IElkProgressMonitor,
) -> MrtreeGraph {
  ignore(self)
  ignore(progress_monitor.begin("@common.Tree layout", 1.0))
  let algorithm = mrtree_update_modules(graph)
  mrtree_layout(graph, algorithm, progress_monitor.sub_task(1.0))
  progress_monitor.done()
  graph
}
