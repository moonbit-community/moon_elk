///|
fn mrtree_level_height_set_level_height(
  current_level : Array[MrtreeNode],
  number_of_nodes : Int,
  direction_value : String,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  if current_level.is_empty() {
    return
  }

  let subtask = match progress_monitor {
    Some(monitor) =>
      monitor.sub_task(
        current_level.length().to_double() / number_of_nodes.to_double(),
      )
    None => None
  }
  match subtask {
    Some(monitor) => ignore(monitor.begin("Set neighbors in level", 1.0))
    None => ()
  }

  let next_level = []
  let mut height = 0.0
  if mrtree_tree_util_direction_is_horizontal(direction_value) {
    for current_node in current_level {
      for child in mrtree_node_children_copy(current_node) {
        next_level.push(child)
      }
      if height < mrtree_node_size(current_node).x {
        height = mrtree_node_size(current_node).x
      }
    }
  } else {
    for current_node in current_level {
      for child in mrtree_node_children_copy(current_node) {
        next_level.push(child)
      }
      if height < mrtree_node_size(current_node).y {
        height = mrtree_node_size(current_node).y
      }
    }
  }

  for current_node in current_level {
    mrtree_node_set_level_height(current_node, height)
  }

  match subtask {
    Some(monitor) => monitor.done()
    None => ()
  }
  mrtree_level_height_set_level_height(
    next_level, number_of_nodes, direction_value, progress_monitor,
  )
}

///|
fn mrtree_level_height_processor_process(
  graph : MrtreeGraph,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  match progress_monitor {
    Some(monitor) =>
      ignore(
        monitor.begin("Processor determine the height for each level", 1.0),
      )
    None => ()
  }

  let number_of_nodes = if mrtree_graph_nodes(graph).is_empty() {
    1
  } else {
    mrtree_graph_nodes(graph).length()
  }

  let mut root : MrtreeNode? = None
  for node in mrtree_graph_nodes(graph) {
    if root == None && mrtree_node_root(node) {
      root = Some(node)
    }
  }

  let direction_value = mrtree_graph_direction(graph)
  match root {
    Some(root_node) =>
      mrtree_level_height_set_level_height(
        [root_node],
        number_of_nodes,
        direction_value,
        progress_monitor,
      )
    None => ()
  }

  match progress_monitor {
    Some(monitor) => monitor.done()
    None => ()
  }
}

///|
pub fn new_mrtree_level_height_processor_layout_processor() -> @core.ILayoutProcessor[
  MrtreeTreeLayoutPhases,
  MrtreeGraph,
] {
  @core.new_layout_processor(mrtree_level_height_processor_process)
}
