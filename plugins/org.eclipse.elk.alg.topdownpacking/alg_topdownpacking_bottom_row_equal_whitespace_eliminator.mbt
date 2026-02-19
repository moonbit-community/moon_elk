///|
fn topdownpacking_expect_node(node : ElkNode?) -> ElkNode {
  match node {
    Some(existing) => existing
    None => abort("Expected node entry in topdownpacking grid.")
  }
}

///|
fn topdownpacking_bottom_row_equal_whitespace_eliminator_configuration(
  graph : GridElkNode,
) -> LayoutProcessorConfiguration[TopdownPackingPhases, GridElkNode]? {
  ignore(graph)
  Some(layout_processor_configuration_create(topdownpacking_phase_descriptor))
}

///|
fn topdownpacking_bottom_row_equal_whitespace_eliminator_process(
  layout_graph : GridElkNode,
  progress_monitor : IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(existing) => existing
    None => new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("Whitespace elimination", 1.0))
  monitor.log(
    "Whitespace elimination began for node \{layout_graph.get_identifier()}",
  )

  if layout_graph.get_width() == 0.0 || layout_graph.get_columns() == 0 {
    monitor.log("Parent node has no width, skipping phase")
    monitor.done()
    return
  }

  let padding = topdownpacking_parse_padding(
    layout_graph.get_string_property(topdownpacking_padding),
  )

  for i = 0; i < layout_graph.get_rows(); i = i + 1 {
    let row = layout_graph.get_row(i)
    let mut last : ElkNode? = None
    let mut last_index = row.length()
    while last == None {
      last_index = last_index - 1
      last = row[last_index]
    }
    let last_node = topdownpacking_expect_node(last)
    let right_border = node_x(last_node) + node_width(last_node)
    if right_border + padding.right < layout_graph.get_width() {
      monitor.log("Eliminate white space in row \{i}")
      let extra_space = layout_graph.get_width() -
        (right_border + padding.right)
      let extra_space_per_node = extra_space / (last_index + 1).to_double()
      let mut accumulated_shift = 0.0
      for j = 0; j <= last_index; j = j + 1 {
        let node = topdownpacking_expect_node(row[j])
        node_set_location(node, node_x(node) + accumulated_shift, node_y(node))
        node_set_dimensions(
          node,
          node_width(node) + extra_space_per_node,
          node_height(node),
        )
        accumulated_shift = accumulated_shift + extra_space_per_node
      }
    }
  }

  let col = layout_graph.get_column(0)
  let last = topdownpacking_expect_node(col[col.length() - 1])
  let bottom_border = node_y(last) + node_height(last)
  let extra_space = layout_graph.get_height() - (bottom_border + padding.bottom)
  let extra_space_per_node = extra_space / (col.length() + 1).to_double()
  let mut accumulated_shift = 0.0
  monitor.log("Eliminate vertical white space")
  if bottom_border + padding.bottom < layout_graph.get_height() {
    for i = 0; i < layout_graph.get_rows(); i = i + 1 {
      let row = layout_graph.get_row(i)
      for node_opt in row {
        match node_opt {
          Some(node) => {
            node_set_location(
              node,
              node_x(node),
              node_y(node) + accumulated_shift,
            )
            node_set_dimensions(
              node,
              node_width(node),
              node_height(node) + extra_space_per_node,
            )
            accumulated_shift = accumulated_shift + extra_space_per_node
          }
          None => break
        }
      }
    }
  }

  monitor.log_graph("Graph after whitespace elimination")
  monitor.done()
}

///|
pub fn new_topdownpacking_bottom_row_equal_whitespace_eliminator_layout_phase() -> ILayoutProcessor[
  TopdownPackingPhases,
  GridElkNode,
] {
  new_layout_phase(
    topdownpacking_bottom_row_equal_whitespace_eliminator_process, topdownpacking_bottom_row_equal_whitespace_eliminator_configuration,
  )
}
