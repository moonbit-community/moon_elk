///|
pub fn rectpacking_compute_scale_measure(
  width : Double,
  height : Double,
  desired_aspect_ratio : Double,
) -> Double {
  @math.minimum(desired_aspect_ratio / width, 1.0 / height)
}

///|
pub fn rectpacking_reset_coordinates(graph : Array[ElkNode]) -> Unit {
  for node in graph {
    node_set_location(node, 0.0, 0.0)
  }
}

///|
pub fn rectpacking_calculate_dimensions_rows(
  rows : Array[RectRow],
  node_node_spacing : Double,
) -> KVector {
  let mut max_width = 0.0
  let mut new_height = 0.0
  let mut index = 0
  for row in rows {
    max_width = @math.maximum(max_width, row.width)
    new_height += row.height + (if index > 0 { node_node_spacing } else { 0.0 })
    index += 1
  }
  new_kvector_xy(max_width, new_height)
}

///|
pub fn rectpacking_calculate_dimensions_rectangles(
  rectangles : Array[ElkNode],
) -> KVector {
  let mut max_width = 0.0
  let mut max_height = 0.0
  for node in rectangles {
    max_width = @math.maximum(node_width(node) + node_x(node), max_width)
    max_height = @math.maximum(node_height(node) + node_y(node), max_height)
  }
  new_kvector_xy(max_width, max_height)
}
