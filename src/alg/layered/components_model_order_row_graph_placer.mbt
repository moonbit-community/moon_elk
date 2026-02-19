///|
fn layered_model_order_row_contains_side(
  sides : Array[@core.PortSide],
  expected : @core.PortSide,
) -> Bool {
  for side in sides {
    if @core.port_side_to_string(side) == @core.port_side_to_string(expected) {
      return true
    }
  }
  false
}

///|
pub struct LayeredModelOrderRowGraphPlacer {
  base : LayeredAbstractGraphPlacer
}

///|
pub fn new_layered_model_order_row_graph_placer() -> LayeredModelOrderRowGraphPlacer {
  { base: new_layered_abstract_graph_placer() }
}

///|
pub fn LayeredModelOrderRowGraphPlacer::combine(
  self : LayeredModelOrderRowGraphPlacer,
  components : Array[LGraph],
  target : LGraph,
) -> Unit {
  if components.length() == 1 {
    let source = components[0]
    self.base.move_graph(target, source, 0.0, 0.0)
    target.copy_properties(source)
    let size = source.get_size()
    target.set_size_xy(size.x, size.y)
    return
  } else if components.is_empty() {
    target.set_size_xy(0.0, 0.0)
    return
  }

  self.sort_components(components, target)

  let first_component = components[0]
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
      let offset = compactor.get_offset()
      graph.set_offset_xy(offset.x, offset.y)
    }
    let graph_size = compactor.get_graph_size()
    target.set_size_xy(graph_size.x, graph_size.y)
  }

  self.base.move_graphs(target, components, 0.0, 0.0)
}

///|
pub fn LayeredModelOrderRowGraphPlacer::sort_components(
  self : LayeredModelOrderRowGraphPlacer,
  components : Array[LGraph],
  target : LGraph,
) -> Unit {
  ignore(self)
  ignore(components)
  ignore(target)
}

///|
pub fn LayeredModelOrderRowGraphPlacer::place_components(
  self : LayeredModelOrderRowGraphPlacer,
  components : Array[LGraph],
  target : LGraph,
  max_row_width : Double,
  component_spacing : Double,
) -> Unit {
  let mut xpos = 0.0
  let mut ypos = 0.0
  let mut highest_box = 0.0
  let mut broadest_row = component_spacing
  let mut start_x_of_row = 0.0
  let mut last_component : LGraph? = None

  for graph in components {
    let size = graph.get_size()
    let sides = graph.get_property_port_side_array(
      internal_properties_ext_port_connections,
    )

    let mut break_row = xpos + size.x > max_row_width &&
      !layered_model_order_row_contains_side(sides, North)

    match last_component {
      Some(last) =>
        if layered_model_order_row_contains_side(
            last.get_property_port_side_array(
              internal_properties_ext_port_connections,
            ),
            East,
          ) {
          break_row = true
        }
      None => ()
    }

    if layered_model_order_row_contains_side(sides, West) {
      break_row = true
    }

    if break_row {
      xpos = start_x_of_row
      ypos += highest_box + component_spacing
      highest_box = 0.0
    }

    if layered_model_order_row_contains_side(sides, North) {
      xpos = broadest_row + component_spacing
    }

    self.base.offset_graph(graph, xpos, ypos)
    broadest_row = layered_components_max(broadest_row, xpos + size.x)

    if layered_model_order_row_contains_side(sides, South) {
      start_x_of_row = layered_components_max(
        start_x_of_row,
        xpos + size.x + component_spacing,
      )
    }

    highest_box = layered_components_max(highest_box, size.y)
    xpos += size.x + component_spacing
    last_component = Some(graph)
  }

  target.set_size_xy(broadest_row, ypos + highest_box)
}
