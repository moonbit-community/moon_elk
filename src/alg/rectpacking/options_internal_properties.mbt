///|
pub let rectpacking_internal_additional_height : @graph.IProperty[Double] = @graph.new_property(
  "additionalHeight", 0.0,
)

///|
pub let rectpacking_internal_drawing_height : @graph.IProperty[Double] = @graph.new_property(
  "drawingHeight", 0.0,
)

///|
pub let rectpacking_internal_drawing_width : @graph.IProperty[Double] = @graph.new_property(
  "drawingWidth", 0.0,
)

///|
pub let rectpacking_internal_min_height : @graph.IProperty[Double] = @graph.new_property(
  "minHeight", 0.0,
)

///|
pub let rectpacking_internal_min_width : @graph.IProperty[Double] = @graph.new_property(
  "minWidth", 0.0,
)

///|
pub let rectpacking_internal_target_width : @graph.IProperty[Double] = @graph.new_property(
  "targetWidth", 0.0,
)

///|
pub let rectpacking_internal_min_row_increase : @graph.IProperty[Double] = @graph.new_property(
  "minRowIncrease", 0.0,
)

///|
pub let rectpacking_internal_max_row_increase : @graph.IProperty[Double] = @graph.new_property(
  "maxRowIncrease", 0.0,
)

///|
pub let rectpacking_internal_min_row_decrease : @graph.IProperty[Double] = @graph.new_property(
  "minRowDecrease", 0.0,
)

///|
pub let rectpacking_internal_max_row_decrease : @graph.IProperty[Double] = @graph.new_property(
  "maxRowDecrease", 0.0,
)

///|
let rectpacking_internal_rows_store : Ref[Map[@graph.ElkNode, Array[RectRow]]] = Ref::new({},
)

///|
pub fn rectpacking_internal_set_rows(
  graph : @graph.ElkNode,
  rows : Array[RectRow],
) -> Unit {
  rectpacking_internal_rows_store.val[graph] = rows
}

///|
pub fn rectpacking_internal_get_rows(graph : @graph.ElkNode) -> Array[RectRow]? {
  rectpacking_internal_rows_store.val.get(graph)
}

///|
pub fn rectpacking_internal_has_rows(graph : @graph.ElkNode) -> Bool {
  rectpacking_internal_rows_store.val.contains(graph)
}

///|
pub fn rectpacking_internal_clear_rows(graph : @graph.ElkNode) -> Unit {
  rectpacking_internal_rows_store.val.remove(graph)
}
