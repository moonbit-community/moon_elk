///|
fn layered_components_max(left : Double, right : Double) -> Double {
  if left > right {
    left
  } else {
    right
  }
}

///|
fn layered_components_graph_area(graph : LGraph) -> Double {
  let size = graph.get_size()
  size.x * size.y
}

///|
fn layered_components_graph_less(left : LGraph, right : LGraph) -> Bool {
  let left_priority = left.get_id()
  let right_priority = right.get_id()
  if left_priority != right_priority {
    return left_priority > right_priority
  }
  layered_components_graph_area(left) < layered_components_graph_area(right)
}

///|
pub struct LayeredSimpleRowGraphPlacer {
  base : LayeredAbstractGraphPlacer
}

///|
pub fn new_layered_simple_row_graph_placer() -> LayeredSimpleRowGraphPlacer {
  { base: new_layered_abstract_graph_placer() }
}

///|
pub fn LayeredSimpleRowGraphPlacer::combine(
  self : LayeredSimpleRowGraphPlacer,
  components : Array[LGraph],
  target : LGraph,
) -> Unit {
  if components.length() == 1 {
    let source = components[0]
    if source.get_handle() != target.get_handle() {
      target.get_layerless_nodes().clear()
      self.base.move_graph(target, source, 0.0, 0.0)
      target.copy_properties(source)
      ignore(target.get_padding().copy(source.get_padding()))
      let size = source.get_size()
      target.set_size_xy(size.x, size.y)
    }
    return
  } else if components.is_empty() {
    target.get_layerless_nodes().clear()
    target.set_size_xy(0.0, 0.0)
    return
  }

  self.sort_components(components, target)

  let first_component = components[0]
  target.get_layerless_nodes().clear()
  target.copy_properties(first_component)

  let mut max_row_width = 0.0
  let mut total_area = 0.0
  for graph in components {
    let size = graph.get_size()
    max_row_width = layered_components_max(max_row_width, size.x)
    total_area += size.x * size.y
  }
  max_row_width = layered_components_max(
    max_row_width,
    total_area.sqrt() * target.get_property_double(@core.aspect_ratio),
  )
  let component_spacing = target.get_property_double(
    @core.spacing_component_component,
  )

  self.place_components(components, target, max_row_width, component_spacing)

  if first_component.get_property_bool(
      layered_options_compaction_connected_components,
    ) {
    let compactor = new_layered_components_compactor()
    compactor.compact(components, target.get_size(), component_spacing)
    for graph in components {
      ignore(graph.get_offset().reset().add(compactor.get_offset()))
    }
    let graph_size = compactor.get_graph_size()
    target.set_size_xy(graph_size.x, graph_size.y)
  }

  self.base.move_graphs(target, components, 0.0, 0.0)
}

///|
pub fn LayeredSimpleRowGraphPlacer::sort_components(
  self : LayeredSimpleRowGraphPlacer,
  components : Array[LGraph],
  target : LGraph,
) -> Unit {
  ignore(self)
  let ordering = target.get_property_component_ordering_strategy(
    layered_options_consider_model_order_components,
  )
  if !component_ordering_strategy_equals(
      ordering,
      ComponentOrderingStrategy::NoneType,
    ) {
    return
  }

  for component in components {
    let mut priority = 0
    for node in component.get_layerless_nodes() {
      priority += node.get_property_double(@core.priority).to_int()
    }
    component.set_id(priority)
  }

  let length = components.length()
  for i in 1..<length {
    let current = components[i]
    let mut j = i
    while j > 0 && layered_components_graph_less(current, components[j - 1]) {
      components[j] = components[j - 1]
      j -= 1
    }
    components[j] = current
  }
}

///|
pub fn LayeredSimpleRowGraphPlacer::place_components(
  self : LayeredSimpleRowGraphPlacer,
  components : Array[LGraph],
  target : LGraph,
  max_row_width : Double,
  component_spacing : Double,
) -> Unit {
  let mut xpos = 0.0
  let mut ypos = 0.0
  let mut highest_box = 0.0
  let mut broadest_row = component_spacing

  for graph in components {
    let size = graph.get_size()
    if xpos + size.x > max_row_width {
      xpos = 0.0
      ypos += highest_box + component_spacing
      highest_box = 0.0
    }

    let offset = graph.get_offset()
    self.base.offset_graph(graph, xpos + offset.x, ypos + offset.y)
    ignore(offset.reset())
    broadest_row = layered_components_max(broadest_row, xpos + size.x)
    highest_box = layered_components_max(highest_box, size.y)
    xpos += size.x + component_spacing
  }

  target.set_size_xy(broadest_row, ypos + highest_box)
}
