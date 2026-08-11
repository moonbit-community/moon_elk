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
/// Per-layout data shared by rectangle-packing phases.
///
/// Rows are produced during packing and consumed during whitespace elimination.
/// Keeping them in this session makes that phase dependency explicit and prevents
/// layouts from communicating through a graph-keyed global map.
pub struct RectPackingSession {
  priv rows : Map[@graph.ElkNode, Array[RectRow]]
}

///|
pub fn new_rectpacking_session() -> RectPackingSession {
  { rows: Map([]) }
}

///|
fn RectPackingSession::set_rows(
  self : RectPackingSession,
  graph : @graph.ElkNode,
  rows : Array[RectRow],
) -> Unit {
  self.rows[graph] = rows
}

///|
fn RectPackingSession::get_rows(
  self : RectPackingSession,
  graph : @graph.ElkNode,
) -> Array[RectRow]? {
  self.rows.get(graph)
}

///|
fn RectPackingSession::clear(self : RectPackingSession) -> Unit {
  self.rows.clear()
}
