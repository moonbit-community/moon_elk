///|
pub fn rectpacking_rectangle_expansion_expand(
  rows : Array[RectRow],
  drawing_width : Double,
  additional_height : Double,
  node_node_spacing : Double,
) -> Unit {
  ignore(node_node_spacing)
  if rows.is_empty() {
    return
  }
  let height_per_row = additional_height / rows.length().to_double()
  let mut index = 0
  for row in rows {
    row.set_y(row.y + height_per_row * index.to_double())
    row.expand(drawing_width, height_per_row)
    index += 1
  }
}
