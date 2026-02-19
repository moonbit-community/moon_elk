///|
fn rectpacking_compactor_copy_row_width_change_values(
  graph : @graph.ElkNode,
  compaction : RectpackingRowFillingAndCompaction,
) -> Unit {
  @graph.node_set_double_property(
    graph,
    rectpacking_internal_min_row_increase,
    compaction.potential_row_width_increase_min,
  )
  @graph.node_set_double_property(
    graph,
    rectpacking_internal_max_row_increase,
    compaction.potential_row_width_increase_max,
  )
  @graph.node_set_double_property(
    graph,
    rectpacking_internal_min_row_decrease,
    compaction.potential_row_width_decrease_min,
  )
  @graph.node_set_double_property(
    graph,
    rectpacking_internal_max_row_decrease,
    compaction.potential_row_width_decrease_max,
  )
}

///|
fn rectpacking_compactor_configure_second_iteration(
  layout_graph : @graph.ElkNode,
  clone : @graph.ElkNode,
  drawing : RectpackingDrawingData,
) -> Unit {
  let padding = @core.new_elk_padding()
  padding.parse(
    @graph.node_get_string_property(layout_graph, rectpacking_padding),
  )
  let aspect_ratio = @graph.node_get_double_property(
    layout_graph, rectpacking_aspect_ratio,
  )

  if @graph.node_children(layout_graph).length() > 1 &&
    @graph.node_get_double_property(
      layout_graph, rectpacking_internal_min_row_increase,
    ) !=
    @double.infinity &&
    (drawing.drawing_width + padding.get_horizontal()) /
    (drawing.drawing_height + padding.get_vertical()) <
    aspect_ratio {
    @graph.node_set_double_property(
      clone,
      rectpacking_internal_target_width,
      @graph.node_get_double_property(
        layout_graph, rectpacking_internal_target_width,
      ) +
      @graph.node_get_double_property(
        layout_graph, rectpacking_internal_min_row_increase,
      ),
    )
  } else if @graph.node_children(layout_graph).length() > 1 &&
    @graph.node_get_double_property(
      layout_graph, rectpacking_internal_min_row_decrease,
    ) !=
    @double.infinity &&
    (drawing.drawing_width + padding.get_horizontal()) /
    (drawing.drawing_height + padding.get_vertical()) >
    aspect_ratio {
    @graph.node_set_double_property(
      clone,
      rectpacking_internal_target_width,
      @cmp.maximum(
        @graph.node_get_double_property(
          layout_graph, rectpacking_internal_min_width,
        ),
        @graph.node_get_double_property(
          clone, rectpacking_internal_target_width,
        ) -
        @graph.node_get_double_property(
          layout_graph, rectpacking_internal_min_row_decrease,
        ),
      ),
    )
  }
}

///|
fn rectpacking_compactor_clone_node(
  node : @graph.ElkNode,
  parent : @graph.ElkNode?,
) -> @graph.ElkNode {
  let cloned = @graph.create_node(parent)
  @graph.node_set_dimensions(
    cloned,
    @graph.node_width(node),
    @graph.node_height(node),
  )
  @graph.node_set_identifier(cloned, @graph.node_identifier(node))
  @graph.node_set_location(cloned, @graph.node_x(node), @graph.node_y(node))

  if @graph.node_has_double_property(
      node, rectpacking_width_approximation_target_width,
    ) {
    @graph.node_set_double_property(
      cloned,
      rectpacking_width_approximation_target_width,
      @graph.node_get_double_property(
        node, rectpacking_width_approximation_target_width,
      ),
    )
  }
  if @graph.node_has_double_property(node, rectpacking_current_position) {
    @graph.node_set_double_property(
      cloned,
      rectpacking_current_position,
      @graph.node_get_double_property(node, rectpacking_current_position),
    )
  }
  if @graph.node_has_double_property(node, rectpacking_desired_position) {
    @graph.node_set_double_property(
      cloned,
      rectpacking_desired_position,
      @graph.node_get_double_property(node, rectpacking_desired_position),
    )
  }

  if @graph.node_has_bool_property(node, rectpacking_in_new_row) {
    @graph.node_set_bool_property(
      cloned,
      rectpacking_in_new_row,
      @graph.node_get_bool_property(node, rectpacking_in_new_row),
    )
  }

  cloned
}

///|
fn rectpacking_compactor_clone_graph(node : @graph.ElkNode) -> @graph.ElkNode {
  let clone = rectpacking_compactor_clone_node(node, None)

  @graph.node_set_double_property(
    clone,
    rectpacking_aspect_ratio,
    @graph.node_get_double_property(node, rectpacking_aspect_ratio),
  )
  @graph.node_set_double_property(
    clone,
    rectpacking_spacing_node_node,
    @graph.node_get_double_property(node, rectpacking_spacing_node_node),
  )
  @graph.node_set_string_property(
    clone,
    rectpacking_padding,
    @graph.node_get_string_property(node, rectpacking_padding),
  )
  @graph.node_set_bool_property(
    clone,
    rectpacking_packing_compaction_row_height_reevaluation,
    @graph.node_get_bool_property(
      node, rectpacking_packing_compaction_row_height_reevaluation,
    ),
  )
  @graph.node_set_double_property(
    clone,
    rectpacking_internal_target_width,
    @graph.node_get_double_property(node, rectpacking_internal_target_width),
  )
  @graph.node_set_double_property(
    clone,
    rectpacking_internal_min_width,
    @graph.node_get_double_property(node, rectpacking_internal_min_width),
  )
  @graph.node_set_double_property(
    clone,
    rectpacking_internal_min_height,
    @graph.node_get_double_property(node, rectpacking_internal_min_height),
  )

  for child in @graph.node_children(node) {
    ignore(rectpacking_compactor_clone_node(child, Some(clone)))
  }

  clone
}

///|
fn rectpacking_compactor_copy_position(
  node : @graph.ElkNode,
  other : @graph.ElkNode,
) -> Unit {
  @graph.node_set_dimensions(
    other,
    @graph.node_width(node),
    @graph.node_height(node),
  )
  @graph.node_set_location(other, @graph.node_x(node), @graph.node_y(node))

  let source_children = @graph.node_children(node)
  let target_children = @graph.node_children(other)
  let mut i = 0
  while i < source_children.length() {
    rectpacking_compactor_copy_position(source_children[i], target_children[i])
    i += 1
  }
}

///|
fn rectpacking_compactor_process(
  graph : @graph.ElkNode,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  match progress_monitor {
    Some(monitor) => ignore(monitor.begin("Compaction", 1.0))
    None => ()
  }

  let rectangles = @graph.node_children(graph)
  let aspect_ratio = @graph.node_get_double_property(
    graph, rectpacking_aspect_ratio,
  )
  let node_node_spacing = @graph.node_get_double_property(
    graph, rectpacking_spacing_node_node,
  )
  let padding = @core.new_elk_padding()
  padding.parse(@graph.node_get_string_property(graph, rectpacking_padding))

  let mut second_iteration = new_rectpacking_row_filling_and_compaction(
    aspect_ratio, node_node_spacing,
  )
  let drawing = second_iteration.start(
    rectangles, progress_monitor, graph, padding,
  )

  rectpacking_compactor_copy_row_width_change_values(graph, second_iteration)

  let mut iterations = @graph.node_get_double_property(
    graph, rectpacking_packing_compaction_iterations,
  ).to_int()
  while iterations > 1 {
    let clone = rectpacking_compactor_clone_graph(graph)
    let old_sm = drawing.scale_measure

    rectpacking_compactor_configure_second_iteration(graph, clone, drawing)

    second_iteration = new_rectpacking_row_filling_and_compaction(
      aspect_ratio, node_node_spacing,
    )
    let new_drawing = second_iteration.start(
      rectangles, progress_monitor, clone, padding,
    )

    let new_sm = new_drawing.scale_measure
    if new_sm >= old_sm && new_sm == new_sm {
      let clone_children = @graph.node_children(clone)
      let graph_children = @graph.node_children(graph)
      let mut i = 0
      while i < clone_children.length() {
        rectpacking_compactor_copy_position(
          clone_children[i],
          graph_children[i],
        )
        i += 1
      }
      rectpacking_compactor_copy_row_width_change_values(
        graph, second_iteration,
      )
      drawing.set_drawing_width(new_drawing.drawing_width)
      drawing.set_drawing_height(new_drawing.drawing_height)
    }
    iterations -= 1
  }

  @graph.node_set_double_property(
    graph,
    rectpacking_internal_drawing_height,
    drawing.drawing_height,
  )
  @graph.node_set_double_property(
    graph,
    rectpacking_internal_drawing_width,
    drawing.drawing_width,
  )

  match progress_monitor {
    Some(monitor) => monitor.done()
    None => ()
  }
}

///|
pub fn new_rectpacking_compactor_layout_phase() -> @core.ILayoutProcessor[
  RectPackingLayoutPhases,
  @graph.ElkNode,
] {
  @core.new_layout_phase(rectpacking_compactor_process, _ => None)
}
