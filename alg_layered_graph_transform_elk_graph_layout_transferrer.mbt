///|
pub struct LayeredElkGraphLayoutTransferrer {
  marker : Int
}

///|
pub fn new_layered_elk_graph_layout_transferrer() -> LayeredElkGraphLayoutTransferrer {
  { marker: 0 }
}

///|
pub fn LayeredElkGraphLayoutTransferrer::apply_layout(
  self : LayeredElkGraphLayoutTransferrer,
  layered_graph : LGraph,
) -> Unit {
  ignore(self)
  ignore(recursive_layered_apply_transformed_graph(layered_graph))
}
