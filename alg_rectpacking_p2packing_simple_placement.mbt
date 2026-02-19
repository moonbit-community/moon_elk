///|
fn rectpacking_simple_placement_process(
  graph : ElkNode,
  progress_monitor : IElkProgressMonitor?,
) -> Unit {
  match progress_monitor {
    Some(monitor) => ignore(monitor.begin("No Compaction", 1.0))
    None => ()
  }

  let target_width = node_get_double_property(
    graph, rectpacking_internal_target_width,
  )
  let node_node_spacing = node_get_double_property(
    graph, rectpacking_spacing_node_node,
  )
  let padding = new_elk_padding()
  padding.parse(node_get_string_property(graph, rectpacking_padding))

  rectpacking_reset_coordinates(node_children(graph))

  let rows = rectpacking_initial_placement_place(
    node_children(graph),
    target_width,
    node_node_spacing,
  )

  let size = if rows.is_empty() {
    rectpacking_calculate_dimensions_rectangles(node_children(graph))
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
    node_get_double_property(graph, rectpacking_internal_min_width) -
    padding.get_horizontal(),
  )
  let height = @math.maximum(
    size.y,
    node_get_double_property(graph, rectpacking_internal_min_height) -
    padding.get_vertical(),
  )
  let additional_height = height - size.y
  node_set_double_property(
    graph, rectpacking_internal_additional_height, additional_height,
  )
  node_set_double_property(graph, rectpacking_internal_drawing_width, width)
  node_set_double_property(
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
pub fn new_rectpacking_simple_placement_layout_phase() -> ILayoutProcessor[
  RectPackingLayoutPhases,
  ElkNode,
] {
  new_layout_phase(rectpacking_simple_placement_process, _ => None)
}
