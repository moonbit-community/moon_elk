///|
pub struct RectpackingRowFillingAndCompaction {
  aspect_ratio : Double
  node_node_spacing : Double
  mut potential_row_width_decrease_min : Double
  mut potential_row_width_decrease_max : Double
  mut potential_row_width_increase_min : Double
  mut potential_row_width_increase_max : Double
}

///|
pub fn new_rectpacking_row_filling_and_compaction(
  aspect_ratio : Double,
  node_node_spacing : Double,
) -> RectpackingRowFillingAndCompaction {
  {
    aspect_ratio,
    node_node_spacing,
    potential_row_width_decrease_min: @double.infinity,
    potential_row_width_decrease_max: 0.0,
    potential_row_width_increase_min: @double.infinity,
    potential_row_width_increase_max: 0.0,
  }
}

///|
fn rectpacking_row_filling_adjust_width_and_height(
  compaction : RectpackingRowFillingAndCompaction,
  row : RectRow,
) -> Unit {
  let mut max_height = 0.0
  let mut max_width = 0.0
  let mut index = 0
  for stack in row.stacks {
    stack.update_dimension()
    max_height = @cmp.maximum(max_height, stack.height)
    max_width += stack.width +
      (if index > 0 { compaction.node_node_spacing } else { 0.0 })
    index += 1
  }
  row.height = max_height
  row.width = max_width
}

///|
pub fn RectpackingRowFillingAndCompaction::start(
  self : RectpackingRowFillingAndCompaction,
  rectangles : Array[@graph.ElkNode],
  progress_monitor : @core.IElkProgressMonitor?,
  layout_graph : @graph.ElkNode,
  padding : @core.Spacing,
) -> RectpackingDrawingData {
  ignore(progress_monitor)
  let target_width = @graph.node_get_double_property(
    layout_graph, rectpacking_internal_target_width,
  )
  let min_width = @graph.node_get_double_property(
    layout_graph, rectpacking_internal_min_width,
  )
  let min_height = @graph.node_get_double_property(
    layout_graph, rectpacking_internal_min_height,
  )

  rectpacking_reset_coordinates(@graph.node_children(layout_graph))

  let rows = rectpacking_initial_placement_place(
    @graph.node_children(layout_graph),
    target_width,
    self.node_node_spacing,
  )

  let mut row_idx = 0
  while row_idx < rows.length() {
    let current_row = rows[row_idx]
    if row_idx != 0 {
      let previous_row = rows[row_idx - 1]
      current_row.set_y(
        previous_row.y + previous_row.height + self.node_node_spacing,
      )
    }

    let (_, compact_row_again) = rectpacking_compaction_compact(
      row_idx,
      rows,
      target_width,
      self.node_node_spacing,
      @graph.node_get_bool_property(
        layout_graph, rectpacking_packing_compaction_row_height_reevaluation,
      ),
    )

    if compact_row_again {
      for block in current_row.children {
        block.fixed = false
        block.position_fixed = false
        block.reset_block()
      }
      current_row.reset_stacks()
      current_row.width = target_width
      row_idx -= 1
    } else {
      rectpacking_row_filling_adjust_width_and_height(self, current_row)

      if row_idx + 1 < rows.length() {
        self.potential_row_width_increase_max = @cmp.maximum(
          current_row.width +
          self.node_node_spacing +
          rows[row_idx + 1].first_block().width -
          target_width,
          self.potential_row_width_decrease_max,
        )
        self.potential_row_width_increase_min = @cmp.minimum(
          current_row.width +
          self.node_node_spacing +
          rows[row_idx + 1].first_block().width -
          target_width,
          self.potential_row_width_decrease_min,
        )
        if !current_row.stacks.is_empty() {
          self.potential_row_width_decrease_max = @cmp.maximum(
            self.potential_row_width_decrease_max,
            current_row.stacks[current_row.stacks.length() - 1].width +
            (if current_row.stacks.length() <= 1 {
              0.0
            } else {
              self.node_node_spacing
            }),
          )
          self.potential_row_width_decrease_min = @cmp.minimum(
            self.potential_row_width_decrease_max,
            current_row.stacks[current_row.stacks.length() - 1].width +
            (if current_row.stacks.length() <= 1 {
              0.0
            } else {
              self.node_node_spacing
            }),
          )
        }
      }

      if rows.length() == 1 {
        let last_stack = current_row.stacks[current_row.stacks.length() - 1]
        let last_block = last_stack.blocks[last_stack.blocks.length() - 1]
        for block_row in last_block.rows {
          self.potential_row_width_decrease_max = @cmp.maximum(
            self.potential_row_width_decrease_max,
            last_block.width - block_row.width,
          )
          self.potential_row_width_decrease_min = @cmp.minimum(
            self.potential_row_width_decrease_min,
            last_block.width - block_row.width,
          )
          self.potential_row_width_increase_max = @cmp.maximum(
            self.potential_row_width_increase_max,
            block_row.width + self.node_node_spacing,
          )
          self.potential_row_width_increase_min = @cmp.minimum(
            self.potential_row_width_increase_min,
            block_row.width + self.node_node_spacing,
          )
        }
      }
    }

    row_idx += 1
  }

  let size = rectpacking_calculate_dimensions_rows(rows, self.node_node_spacing)
  let total_width = @cmp.maximum(size.x, min_width - padding.get_horizontal())
  let height = @cmp.maximum(size.y, min_height - padding.get_vertical())
  let additional_height = height - size.y

  @graph.node_set_double_property(
    layout_graph, rectpacking_internal_additional_height, additional_height,
  )
  rectpacking_internal_set_rows(layout_graph, rows)

  ignore(rectangles)
  new_rectpacking_drawing_data(
    self.aspect_ratio,
    total_width,
    size.y + additional_height,
    RectpackingDrawingDataDescriptor::WHOLE_DRAWING,
  )
}
