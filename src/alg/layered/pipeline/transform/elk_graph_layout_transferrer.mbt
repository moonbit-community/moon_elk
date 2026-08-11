///|
pub struct LayeredElkGraphLayoutTransferrer {
  session : LayeredTransformSession
}

///|
pub fn new_layered_elk_graph_layout_transferrer(
  session : LayeredTransformSession,
) -> LayeredElkGraphLayoutTransferrer {
  { session, }
}

///|
pub fn LayeredElkGraphLayoutTransferrer::apply_layout(
  self : LayeredElkGraphLayoutTransferrer,
  layered_graph : LGraph,
) -> Unit {
  ignore(recursive_layered_apply_transformed_graph(self.session, layered_graph))
  dispose_layered_graph(layered_graph)
}
