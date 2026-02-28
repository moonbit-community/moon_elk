///|
fn rectpacking_sort_nodes_by_desired_position(
  nodes : Array[@graph.ElkNode],
) -> Unit {
  let mut i = 1
  while i < nodes.length() {
    let value = nodes[i]
    let mut j = i
    while j > 0 {
      let pos_a = @graph.node_get_double_property(
        nodes[j - 1],
        rectpacking_desired_position,
      ).to_int()
      let pos_b = @graph.node_get_double_property(
        value, rectpacking_desired_position,
      ).to_int()
      let cmp = if pos_a == pos_b { -1 } else if pos_a < pos_b { -1 } else { 1 }
      if cmp <= 0 {
        break
      }
      nodes[j] = nodes[j - 1]
      j -= 1
    }
    nodes[j] = value
    i += 1
  }
}

///|
fn rectpacking_interactive_node_reorderer_process(
  graph : @graph.ElkNode,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  match progress_monitor {
    Some(monitor) => ignore(monitor.begin("Interactive Node Reorderer", 1.0))
    None => ()
  }

  let rectangles = @graph.node_children(graph)
  let fixed_nodes = []
  for node in rectangles {
    if @graph.node_has_double_property(node, rectpacking_desired_position) {
      fixed_nodes.push(node)
    }
  }

  let remaining = []
  for node in rectangles {
    let mut is_fixed = false
    for fixed in fixed_nodes {
      if fixed == node {
        is_fixed = true
        break
      }
    }
    if !is_fixed {
      remaining.push(node)
    }
  }

  rectpacking_sort_nodes_by_desired_position(fixed_nodes)
  for node in fixed_nodes {
    let mut position = @graph.node_get_double_property(
      node, rectpacking_desired_position,
    ).to_int()
    if position > remaining.length() {
      position = remaining.length()
    }
    remaining.insert(position, node)
  }

  rectangles.clear()
  for node in remaining {
    rectangles.push(node)
  }

  let mut index = 0
  for node in rectangles {
    @graph.node_set_double_property(
      node,
      rectpacking_current_position,
      index.to_double(),
    )
    index += 1
  }

  match progress_monitor {
    Some(monitor) => monitor.done()
    None => ()
  }
}

///|
pub fn new_rectpacking_interactive_node_reorderer_layout_processor() -> @core.ILayoutProcessor[
  RectPackingLayoutPhases,
  @graph.ElkNode,
] {
  @core.new_layout_processor(rectpacking_interactive_node_reorderer_process)
}
