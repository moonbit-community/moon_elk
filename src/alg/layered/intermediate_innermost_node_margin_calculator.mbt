///|
fn innermost_node_margin_calculator_min(a : Double, b : Double) -> Double {
  if a < b {
    a
  } else {
    b
  }
}

///|
fn innermost_node_margin_calculator_max(a : Double, b : Double) -> Double {
  if a > b {
    a
  } else {
    b
  }
}

///|
fn innermost_node_margin_calculator_process_node(node : LNode) -> Unit {
  let node_size = node.get_size()
  let mut min_x = 0.0
  let mut min_y = 0.0
  let mut max_x = node_size.x
  let mut max_y = node_size.y

  for label in node.get_labels() {
    let label_pos = label.get_position()
    let label_size = label.get_size()
    min_x = innermost_node_margin_calculator_min(min_x, label_pos.x)
    min_y = innermost_node_margin_calculator_min(min_y, label_pos.y)
    max_x = innermost_node_margin_calculator_max(
      max_x,
      label_pos.x + label_size.x,
    )
    max_y = innermost_node_margin_calculator_max(
      max_y,
      label_pos.y + label_size.y,
    )
  }

  for port in node.get_ports() {
    let port_pos = port.get_position()
    let port_size = port.get_size()

    min_x = innermost_node_margin_calculator_min(min_x, port_pos.x)
    min_y = innermost_node_margin_calculator_min(min_y, port_pos.y)
    max_x = innermost_node_margin_calculator_max(
      max_x,
      port_pos.x + port_size.x,
    )
    max_y = innermost_node_margin_calculator_max(
      max_y,
      port_pos.y + port_size.y,
    )

    for label in port.get_labels() {
      let label_pos = label.get_position()
      let label_size = label.get_size()
      let label_x = port_pos.x + label_pos.x
      let label_y = port_pos.y + label_pos.y

      min_x = innermost_node_margin_calculator_min(min_x, label_x)
      min_y = innermost_node_margin_calculator_min(min_y, label_y)
      max_x = innermost_node_margin_calculator_max(
        max_x,
        label_x + label_size.x,
      )
      max_y = innermost_node_margin_calculator_max(
        max_y,
        label_y + label_size.y,
      )
    }
  }

  let margin = node.get_margin()
  margin.top = innermost_node_margin_calculator_max(0.0, -min_y)
  margin.left = innermost_node_margin_calculator_max(0.0, -min_x)
  margin.bottom = innermost_node_margin_calculator_max(0.0, max_y - node_size.y)
  margin.right = innermost_node_margin_calculator_max(0.0, max_x - node_size.x)
}

///|
fn innermost_node_margin_calculator_process(
  layered_graph : LGraph,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => @core.new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("Node margin calculation", 1.0))

  for node in layered_graph.get_layerless_nodes() {
    innermost_node_margin_calculator_process_node(node)
  }
  for layer in layered_graph.get_layers() {
    for node in layer.get_nodes() {
      innermost_node_margin_calculator_process_node(node)
    }
  }

  monitor.done()
}

///|
pub fn new_innermost_node_margin_calculator_layout_processor() -> @core.ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  @core.new_layout_processor(innermost_node_margin_calculator_process)
}
