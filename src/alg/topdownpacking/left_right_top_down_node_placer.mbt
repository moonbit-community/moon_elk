///|
fn topdownpacking_parse_padding(value : String) -> @core.ElkPadding {
  let padding = @core.new_elk_padding()
  padding.parse(value)
  padding
}

///|
fn topdownpacking_left_right_top_down_node_placer_configuration(
  graph : GridElkNode,
) -> @core.LayoutProcessorConfiguration[TopdownPackingPhases, GridElkNode]? {
  ignore(graph)
  Some(
    @core.layout_processor_configuration_create(topdownpacking_phase_descriptor),
  )
}

///|
fn topdownpacking_left_right_top_down_node_placer_process(
  layout_graph : GridElkNode,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(existing) => existing
    None => @core.new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("Node placement", 1.0))
  monitor.log("Node placement began for node \{layout_graph.get_identifier()}")

  let padding = topdownpacking_parse_padding(
    layout_graph.get_string_property(topdownpacking_padding),
  )
  let node_node_spacing = layout_graph.get_double_property(
    topdownpacking_spacing_node_node,
  )

  let graph_size = topdownpacking_left_right_top_down_node_placer_get_predicted_size(
    layout_graph.get_node(),
  )
  let updated_width = if layout_graph.get_width() > graph_size.x {
    layout_graph.get_width()
  } else {
    graph_size.x
  }
  let updated_height = if layout_graph.get_height() > graph_size.y {
    layout_graph.get_height()
  } else {
    graph_size.y
  }
  layout_graph.set_dimensions(updated_width, updated_height)

  let nodes = layout_graph.get_children().copy()
  let cols = nodes.length().to_double().sqrt().ceil().to_int()
  let rows = if nodes.length() > cols * cols - cols || cols == 0 {
    cols
  } else {
    cols - 1
  }
  layout_graph.set_grid_size(cols, rows)

  monitor.log(
    "\{layout_graph.get_identifier()}\nPlacing \{nodes.length()} nodes in \{cols} columns.",
  )
  monitor.done()
  monitor.log("Node Arrangement done!")

  let mut curr_x = padding.left
  let mut curr_y = padding.top
  let mut current_col = 0
  let mut current_row = 0
  let desired_node_width = layout_graph.get_double_property(
    topdownpacking_hierarchical_node_width,
  )
  let aspect_ratio = layout_graph.get_double_property(
    topdownpacking_hierarchical_node_aspect_ratio,
  )

  for node in nodes {
    @graph.node_set_dimensions(
      node,
      desired_node_width,
      desired_node_width / aspect_ratio,
    )
    @graph.node_set_location(node, curr_x, curr_y)
    monitor.log("currX: \{curr_x}")
    monitor.log("currY: \{curr_y}")
    layout_graph.put(current_col, current_row, node)
    monitor.log_graph(
      "\{@graph.node_identifier(node)} placed in (\{current_col}|\{current_row})",
    )

    curr_x = curr_x + @graph.node_width(node) + node_node_spacing
    current_col = current_col + 1
    if current_col >= cols {
      curr_x = padding.left
      curr_y = curr_y + desired_node_width / aspect_ratio + node_node_spacing
      current_col = 0
      current_row = current_row + 1
    }
  }

  monitor.log("Node Placing done!")
  monitor.log_graph("Graph after node placement")
  monitor.done()
}

///|
pub fn topdownpacking_left_right_top_down_node_placer_get_predicted_size(
  graph : @graph.ElkNode,
) -> @core.KVector {
  let number_of_children = @graph.node_children(graph).length()
  let padding = topdownpacking_parse_padding(
    @graph.node_get_string_property(graph, topdownpacking_padding),
  )
  let node_node_spacing = @graph.node_get_double_property(
    graph, topdownpacking_spacing_node_node,
  )
  let hierarchical_node_width = @graph.node_get_double_property(
    graph, topdownpacking_hierarchical_node_width,
  )
  let hierarchical_node_aspect_ratio = @graph.node_get_double_property(
    graph, topdownpacking_hierarchical_node_aspect_ratio,
  )

  let cols = number_of_children.to_double().sqrt().ceil().to_int()
  let required_width = cols.to_double() * hierarchical_node_width +
    padding.left +
    padding.right +
    (cols - 1).to_double() * node_node_spacing
  let rows = if number_of_children > cols * cols - cols || cols == 0 {
    cols
  } else {
    cols - 1
  }
  let required_height = rows.to_double() *
    hierarchical_node_width /
    hierarchical_node_aspect_ratio +
    padding.top +
    padding.bottom +
    (rows - 1).to_double() * node_node_spacing
  @core.new_kvector_xy(required_width, required_height)
}

///|
pub fn new_topdownpacking_left_right_top_down_node_placer_layout_phase() -> @core.ILayoutProcessor[
  TopdownPackingPhases,
  GridElkNode,
] {
  @core.new_layout_phase(
    topdownpacking_left_right_top_down_node_placer_process, topdownpacking_left_right_top_down_node_placer_configuration,
  )
}

///|
pub fn new_topdownpacking_left_right_top_down_node_placer_node_arranger() -> INodeArranger {
  new_node_arranger(
    topdownpacking_left_right_top_down_node_placer_get_predicted_size,
  )
}
