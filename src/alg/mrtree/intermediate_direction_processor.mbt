///|
fn mrtree_direction_processor_process(
  graph : MrtreeGraph,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  match progress_monitor {
    Some(monitor) => ignore(monitor.begin("Process directions", 1.0))
    None => ()
  }

  let direction_value = mrtree_graph_direction(graph)
  if direction_value != "DOWN" {
    for node in mrtree_graph_nodes(graph) {
      let mut x = mrtree_node_xcoor(node)
      let mut y = mrtree_node_ycoor(node)
      if direction_value == "UP" {
        y = -y
      } else if direction_value == "RIGHT" {
        let tmp = x
        x = y
        y = tmp
      } else if direction_value == "LEFT" {
        let tmp = x
        x = -y
        y = tmp
      }
      mrtree_node_set_xcoor(node, x)
      mrtree_node_set_ycoor(node, y)
    }
  }

  match progress_monitor {
    Some(monitor) => monitor.done()
    None => ()
  }
}

///|
pub fn new_mrtree_direction_processor_layout_processor() -> @core.ILayoutProcessor[
  MrtreeTreeLayoutPhases,
  MrtreeGraph,
] {
  @core.new_layout_processor(mrtree_direction_processor_process)
}
