///|
fn mrtree_node_position_set_coordinates(
  current_level : Array[MrtreeNode],
  progress_monitor : @core.IElkProgressMonitor?,
) -> Array[MrtreeNode] {
  ignore(progress_monitor)
  if current_level.is_empty() {
    return []
  }
  let next_level = []
  for node in current_level {
    for child in mrtree_node_children_copy(node) {
      next_level.push(child)
    }
    let position = mrtree_node_position(node)
    position.x = mrtree_node_xcoor(node).to_double()
    position.y = mrtree_node_ycoor(node).to_double()
  }
  next_level
}

///|
fn mrtree_node_position_processor_process(
  graph : MrtreeGraph,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  match progress_monitor {
    Some(monitor) => ignore(monitor.begin("Processor set coordinates", 1.0))
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
      let position = mrtree_node_position(node)
      position.x = mrtree_node_xcoor(node).to_double()
      position.y = mrtree_node_ycoor(node).to_double()
    }
  }

  let mut next_level = match root {
    Some(root_node) => mrtree_node_children_copy(root_node)
    None => []
  }
  let mut subtasks = 1.0
  let mut continue_loop = true
  while continue_loop {
    next_level = mrtree_node_position_set_coordinates(
      next_level,
      match progress_monitor {
        Some(monitor) => monitor.sub_task(subtasks)
        None => None
      },
    )
    subtasks = next_level.length().to_double() / number_of_nodes.to_double()
    continue_loop = !next_level.is_empty()
  }

  for node in mrtree_graph_nodes(graph) {
    let position = mrtree_node_position(node)
    let size = mrtree_node_size(node)
    ignore(position.sub(@core.new_kvector_xy(size.x / 2.0, size.y / 2.0)))
  }

  match progress_monitor {
    Some(monitor) => monitor.done()
    None => ()
  }
}

///|
pub fn new_mrtree_node_position_processor_layout_processor() -> @core.ILayoutProcessor[
  MrtreeTreeLayoutPhases,
  MrtreeGraph,
] {
  @core.new_layout_processor(mrtree_node_position_processor_process)
}
