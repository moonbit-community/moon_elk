///|
fn mrtree_level_coordinates_processor_process(
  graph : MrtreeGraph,
  progress_monitor : IElkProgressMonitor?,
) -> Unit {
  match progress_monitor {
    Some(monitor) =>
      ignore(
        monitor.begin("Processor determine the coords for each level", 1.0),
      )
    None => ()
  }

  let levels : Array[KVector] = []
  let direction_value = mrtree_graph_direction(graph)

  for node in mrtree_graph_nodes(graph) {
    while mrtree_node_tree_level(node) > levels.length() - 1 {
      levels.push(new_kvector_xy(1.0e20, -1.0e20))
    }
    let current_level = mrtree_node_tree_level(node)
    let level_bounds = levels[current_level]
    let position = mrtree_node_position(node)
    let size = mrtree_node_size(node)
    if mrtree_tree_util_direction_is_horizontal(direction_value) {
      if position.x < level_bounds.x {
        level_bounds.x = position.x
      }
      if position.x + size.x > level_bounds.y {
        level_bounds.y = position.x + size.x
      }
    } else {
      if position.y < level_bounds.x {
        level_bounds.x = position.y
      }
      if position.y + size.y > level_bounds.y {
        level_bounds.y = position.y + size.y
      }
    }
  }

  for node in mrtree_graph_nodes(graph) {
    let level_bounds = levels[mrtree_node_tree_level(node)]
    mrtree_node_set_level_min(node, level_bounds.x)
    mrtree_node_set_level_max(node, level_bounds.y)
  }

  match progress_monitor {
    Some(monitor) => monitor.done()
    None => ()
  }
}

///|
pub fn new_mrtree_level_coordinates_processor_layout_processor() -> ILayoutProcessor[
  MrtreeTreeLayoutPhases,
  MrtreeGraph,
] {
  new_layout_processor(mrtree_level_coordinates_processor_process)
}
