///|
fn rectpacking_simple_placement_process(
  graph : @graph.ElkNode,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  match progress_monitor {
    Some(monitor) => ignore(monitor.begin("No Compaction", 1.0))
    None => ()
  }

  let target_width = @graph.node_get_double_property(
    graph, rectpacking_internal_target_width,
  )
  let node_node_spacing = @graph.node_get_double_property(
    graph, rectpacking_spacing_node_node,
  )
  let padding = @core.new_elk_padding()
  padding.parse(@graph.node_get_string_property(graph, rectpacking_padding))

  rectpacking_reset_coordinates(@graph.node_children(graph))

  let rows = rectpacking_initial_placement_place(
    @graph.node_children(graph),
    target_width,
    node_node_spacing,
  )

  let size = if rows.is_empty() {
    rectpacking_calculate_dimensions_rectangles(@graph.node_children(graph))
  } else {
    for row in rows {
      for block in row.children {
        let stack = new_rectpacking_block_stack(
          block.x,
          block.y,
          node_node_spacing,
        )
        stack.add_block(block)
        row.stacks.push(stack)
      }
    }
    rectpacking_calculate_dimensions_rows(rows, node_node_spacing)
  }

  let width = @math.maximum(
    size.x,
    @graph.node_get_double_property(graph, rectpacking_internal_min_width) -
    padding.get_horizontal(),
  )
  let height = @math.maximum(
    size.y,
    @graph.node_get_double_property(graph, rectpacking_internal_min_height) -
    padding.get_vertical(),
  )
  let additional_height = height - size.y
  @graph.node_set_double_property(
    graph, rectpacking_internal_additional_height, additional_height,
  )
  @graph.node_set_double_property(graph, rectpacking_internal_drawing_width, width)
  @graph.node_set_double_property(
    graph,
    rectpacking_internal_drawing_height,
    height + additional_height,
  )
  rectpacking_internal_set_rows(graph, rows)

  match progress_monitor {
    Some(monitor) => monitor.done()
    None => ()
  }
}

///|
pub fn new_rectpacking_simple_placement_layout_phase() -> @core.ILayoutProcessor[
  RectPackingLayoutPhases,
  @graph.ElkNode,
] {
  @core.new_layout_phase(rectpacking_simple_placement_process, _ => None)
}
