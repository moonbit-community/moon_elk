///|
pub struct LayeredComponentsCompactor {
  mut offset : KVector
  mut graph_size : KVector
}

///|
pub fn new_layered_components_compactor() -> LayeredComponentsCompactor {
  { offset: new_kvector(), graph_size: new_kvector() }
}

///|
pub fn LayeredComponentsCompactor::compact(
  self : LayeredComponentsCompactor,
  graphs : Array[LGraph],
  original_graph_size : KVector,
  spacing : Double,
) -> Unit {
  ignore(spacing)
  if graphs.is_empty() {
    self.offset = new_kvector()
    self.graph_size = original_graph_size.clone()
    return
  }

  let mut min_x = @double.infinity
  let mut min_y = @double.infinity
  let mut max_x = -@double.infinity
  let mut max_y = -@double.infinity

  for graph in graphs {
    let graph_offset = graph.get_offset()
    let graph_size = graph.get_size()

    if graph_offset.x < min_x {
      min_x = graph_offset.x
    }
    if graph_offset.y < min_y {
      min_y = graph_offset.y
    }
    if graph_offset.x + graph_size.x > max_x {
      max_x = graph_offset.x + graph_size.x
    }
    if graph_offset.y + graph_size.y > max_y {
      max_y = graph_offset.y + graph_size.y
    }
  }

  self.offset = new_kvector_xy(-min_x, -min_y)
  self.graph_size = new_kvector_xy(max_x - min_x, max_y - min_y)
}

///|
pub fn LayeredComponentsCompactor::get_offset(
  self : LayeredComponentsCompactor,
) -> KVector {
  self.offset
}

///|
pub fn LayeredComponentsCompactor::get_graph_size(
  self : LayeredComponentsCompactor,
) -> KVector {
  self.graph_size
}
