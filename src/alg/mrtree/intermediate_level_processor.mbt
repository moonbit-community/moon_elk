///|
fn mrtree_level_set_level(
  current_level : Array[MrtreeNode],
  level : Int,
  global_level_map : Map[Int, Int],
) -> Unit {
  if current_level.is_empty() {
    return
  }
  let next_level = []
  for node in current_level {
    global_level_map[mrtree_node_id(node)] = level
    for child in mrtree_node_children_copy(node) {
      next_level.push(child)
    }
  }
  mrtree_level_set_level(next_level, level + 1, global_level_map)
}

///|
fn mrtree_level_processor_process(
  graph : MrtreeGraph,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  match progress_monitor {
    Some(monitor) => ignore(monitor.begin("Processor compute fanout", 1.0))
    None => ()
  }

  let roots = []
  for node in mrtree_graph_nodes(graph) {
    if mrtree_node_root(node) {
      roots.push(node)
    }
  }

  let global_level_map : Map[Int, Int] = {}
  mrtree_level_set_level(roots, 0, global_level_map)

  for node in mrtree_graph_nodes(graph) {
    let level = match global_level_map.get(mrtree_node_id(node)) {
      Some(value) => value
      None => 0
    }
    mrtree_node_set_tree_level(node, level)
  }

  match progress_monitor {
    Some(monitor) => monitor.done()
    None => ()
  }
}

///|
pub fn new_mrtree_level_processor_layout_processor() -> @core.ILayoutProcessor[
  MrtreeTreeLayoutPhases,
  MrtreeGraph,
] {
  @core.new_layout_processor(mrtree_level_processor_process)
}
