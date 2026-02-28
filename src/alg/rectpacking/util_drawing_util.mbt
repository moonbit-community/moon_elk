///|
pub fn rectpacking_compute_scale_measure(
  width : Double,
  height : Double,
  desired_aspect_ratio : Double,
) -> Double {
  @cmp.minimum(desired_aspect_ratio / width, 1.0 / height)
}

///|
pub fn rectpacking_reset_coordinates(graph : Array[@graph.ElkNode]) -> Unit {
  for node in graph {
    @graph.node_set_location(node, 0.0, 0.0)
  }
}

///|
pub fn rectpacking_calculate_dimensions_rows(
  rows : Array[RectRow],
  node_node_spacing : Double,
) -> @core.KVector {
  let mut max_width = 0.0
  let mut new_height = 0.0
  let mut index = 0
  for row in rows {
    max_width = @cmp.maximum(max_width, row.width)
    new_height += row.height + (if index > 0 { node_node_spacing } else { 0.0 })
    index += 1
  }
  @core.new_kvector_xy(max_width, new_height)
}

///|
pub fn rectpacking_calculate_dimensions_rectangles(
  rectangles : Array[@graph.ElkNode],
) -> @core.KVector {
  let mut max_width = 0.0
  let mut max_height = 0.0
  for node in rectangles {
    max_width = @cmp.maximum(
      @graph.node_width(node) + @graph.node_x(node),
      max_width,
    )
    max_height = @cmp.maximum(
      @graph.node_height(node) + @graph.node_y(node),
      max_height,
    )
  }
  @core.new_kvector_xy(max_width, max_height)
}
