///|
fn mrtree_neighbors_set_neighbors(
  current_level : Array[MrtreeNode],
  number_of_nodes : Int,
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
  let mut left_node : MrtreeNode? = None
  for current_node in current_level {
    for child in mrtree_node_children_copy(current_node) {
      next_level.push(child)
    }
    match left_node {
      Some(left_neighbor) => {
        mrtree_node_set_right_neighbor(left_neighbor, Some(current_node))
        mrtree_node_set_left_neighbor(current_node, Some(left_neighbor))
        if mrtree_node_parent(current_node) == mrtree_node_parent(left_neighbor) {
          mrtree_node_set_right_sibling(left_neighbor, Some(current_node))
          mrtree_node_set_left_sibling(current_node, Some(left_neighbor))
        }
      }
      None => ()
    }
    left_node = Some(current_node)
  }

  match subtask {
    Some(monitor) => monitor.done()
    None => ()
  }
  mrtree_neighbors_set_neighbors(next_level, number_of_nodes, progress_monitor)
}

///|
fn mrtree_neighbors_processor_process(
  graph : MrtreeGraph,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  match progress_monitor {
    Some(monitor) => ignore(monitor.begin("Processor set neighbors", 1.0))
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
    mrtree_node_set_left_neighbor(node, None)
    mrtree_node_set_right_neighbor(node, None)
    mrtree_node_set_left_sibling(node, None)
    mrtree_node_set_right_sibling(node, None)
  }

  match root {
    Some(root_node) =>
      mrtree_neighbors_set_neighbors(
        mrtree_node_children_copy(root_node),
        number_of_nodes,
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
pub fn new_mrtree_neighbors_processor_layout_processor() -> @core.ILayoutProcessor[
  MrtreeTreeLayoutPhases,
  MrtreeGraph,
] {
  @core.new_layout_processor(mrtree_neighbors_processor_process)
}
