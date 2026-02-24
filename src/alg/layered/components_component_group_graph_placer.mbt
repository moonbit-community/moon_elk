///|
fn _layered_components_max3(a : Double, b : Double, c : Double) -> Double {
  layered_components_max(a, layered_components_max(b, c))
}

///|
fn layered_components_max4(
  a : Double,
  b : Double,
  c : Double,
  d : Double,
) -> Double {
  layered_components_max(
    layered_components_max(a, b),
    layered_components_max(c, d),
  )
}

///|
pub struct LayeredComponentGroupGraphPlacer {
  base : LayeredAbstractGraphPlacer
  component_groups : Array[ComponentGroup]
}

///|
pub fn new_layered_component_group_graph_placer() -> LayeredComponentGroupGraphPlacer {
  { base: new_layered_abstract_graph_placer(), component_groups: [] }
}

///|
pub fn LayeredComponentGroupGraphPlacer::combine(
  self : LayeredComponentGroupGraphPlacer,
  components : Array[LGraph],
  target : LGraph,
) -> Unit {
  self.component_groups.clear()
  target.get_layerless_nodes().clear()

  if components.is_empty() {
    target.set_size_xy(0.0, 0.0)
    return
  }

  let first_component = components[0]
  target.copy_properties(first_component)

  for component in components {
    self.add_component(component)
  }

  let offset = @core.new_kvector()
  let component_spacing = first_component.get_property_double(
    @core.spacing_component_component,
  )

  for group in self.component_groups {
    let group_size = self.place_components(group, component_spacing)
    self.base.offset_graphs(group.get_components(), offset.x, offset.y)

    offset.x += group_size.x
    offset.y += group_size.y
  }

  target.set_size_xy(offset.x - component_spacing, offset.y - component_spacing)

  if first_component.get_property_bool(
      layered_options_compaction_connected_components,
    ) &&
    first_component.get_property_string(@core.edge_routing) == "ORTHOGONAL" {
    for graph in components {
      let graph_offset = graph.get_offset()
      self.base.offset_graph(graph, graph_offset.x, graph_offset.y)
    }

    let compactor = new_layered_components_compactor()
    compactor.compact(components, target.get_size(), component_spacing)

    for graph in components {
      ignore(graph.get_offset().reset().add(compactor.get_offset()))
    }

    let compacted_size = compactor.get_graph_size()
    target.set_size_xy(compacted_size.x, compacted_size.y)
  }

  for group in self.component_groups {
    self.base.move_graphs(target, group.get_components(), 0.0, 0.0)
  }
}

///|
pub fn LayeredComponentGroupGraphPlacer::add_component(
  self : LayeredComponentGroupGraphPlacer,
  component : LGraph,
) -> Unit {
  for group in self.component_groups {
    if group.add(component) {
      return
    }
  }
  self.component_groups.push(new_component_group_with_component(component))
}

///|
pub fn LayeredComponentGroupGraphPlacer::place_components(
  self : LayeredComponentGroupGraphPlacer,
  group : ComponentGroup,
  spacing : Double,
) -> @core.KVector {
  let size_c = self.place_components_in_rows(
    group.get_components_with_connections(@core.sides_none),
    spacing,
  )
  let size_n = self.place_components_horizontally(
    group.get_components_with_connections(@core.sides_north),
    spacing,
  )
  let size_s = self.place_components_horizontally(
    group.get_components_with_connections(@core.sides_south),
    spacing,
  )
  let size_w = self.place_components_vertically(
    group.get_components_with_connections(@core.sides_west),
    spacing,
  )
  let size_e = self.place_components_vertically(
    group.get_components_with_connections(@core.sides_east),
    spacing,
  )
  let size_nw = self.place_components_horizontally(
    group.get_components_with_connections(@core.sides_north_west),
    spacing,
  )
  let size_ne = self.place_components_horizontally(
    group.get_components_with_connections(@core.sides_north_east),
    spacing,
  )
  let size_sw = self.place_components_horizontally(
    group.get_components_with_connections(@core.sides_south_west),
    spacing,
  )
  let size_se = self.place_components_horizontally(
    group.get_components_with_connections(@core.sides_east_south),
    spacing,
  )
  let size_we = self.place_components_vertically(
    group.get_components_with_connections(@core.sides_east_west),
    spacing,
  )
  let size_ns = self.place_components_horizontally(
    group.get_components_with_connections(@core.sides_north_south),
    spacing,
  )
  let size_nwe = self.place_components_horizontally(
    group.get_components_with_connections(@core.sides_north_east_west),
    spacing,
  )
  let size_swe = self.place_components_horizontally(
    group.get_components_with_connections(@core.sides_east_south_west),
    spacing,
  )
  let size_wns = self.place_components_vertically(
    group.get_components_with_connections(@core.sides_north_south_west),
    spacing,
  )
  let size_ens = self.place_components_vertically(
    group.get_components_with_connections(@core.sides_north_east_south),
    spacing,
  )
  let size_nesw = self.place_components_horizontally(
    group.get_components_with_connections(@core.sides_north_east_south_west),
    spacing,
  )

  let col_left_width = layered_components_max4(
    size_nw.x,
    size_w.x,
    size_sw.x,
    size_wns.x,
  )
  let col_mid_width = layered_components_max4(
    size_n.x,
    size_c.x,
    size_s.x,
    size_nesw.x,
  )
  let col_ns_width = size_ns.x
  let col_right_width = layered_components_max4(
    size_ne.x,
    size_e.x,
    size_se.x,
    size_ens.x,
  )
  let row_top_height = layered_components_max4(
    size_nw.y,
    size_n.y,
    size_ne.y,
    size_nwe.y,
  )
  let row_mid_height = layered_components_max4(
    size_w.y,
    size_c.y,
    size_e.y,
    size_nesw.y,
  )
  let row_we_height = size_we.y
  let row_bottom_height = layered_components_max4(
    size_sw.y,
    size_s.y,
    size_se.y,
    size_swe.y,
  )

  self.base.offset_graphs(
    group.get_components_with_connections(@core.sides_none),
    col_left_width + col_ns_width,
    row_top_height + row_we_height,
  )
  self.base.offset_graphs(
    group.get_components_with_connections(@core.sides_north_east_south_west),
    col_left_width + col_ns_width,
    row_top_height + row_we_height,
  )
  self.base.offset_graphs(
    group.get_components_with_connections(@core.sides_north),
    col_left_width + col_ns_width,
    0.0,
  )
  self.base.offset_graphs(
    group.get_components_with_connections(@core.sides_south),
    col_left_width + col_ns_width,
    row_top_height + row_we_height + row_mid_height,
  )
  self.base.offset_graphs(
    group.get_components_with_connections(@core.sides_west),
    0.0,
    row_top_height + row_we_height,
  )
  self.base.offset_graphs(
    group.get_components_with_connections(@core.sides_east),
    col_left_width + col_ns_width + col_mid_width,
    row_top_height + row_we_height,
  )
  self.base.offset_graphs(
    group.get_components_with_connections(@core.sides_north_east),
    col_left_width + col_ns_width + col_mid_width,
    0.0,
  )
  self.base.offset_graphs(
    group.get_components_with_connections(@core.sides_south_west),
    0.0,
    row_top_height + row_we_height + row_mid_height,
  )
  self.base.offset_graphs(
    group.get_components_with_connections(@core.sides_east_south),
    col_left_width + col_ns_width + col_mid_width,
    row_top_height + row_we_height + row_mid_height,
  )
  self.base.offset_graphs(
    group.get_components_with_connections(@core.sides_east_west),
    0.0,
    row_top_height,
  )
  self.base.offset_graphs(
    group.get_components_with_connections(@core.sides_north_south),
    col_left_width,
    0.0,
  )
  self.base.offset_graphs(
    group.get_components_with_connections(@core.sides_east_south_west),
    0.0,
    row_top_height + row_we_height + row_mid_height,
  )
  self.base.offset_graphs(
    group.get_components_with_connections(@core.sides_north_east_south),
    col_left_width + col_ns_width + col_mid_width,
    0.0,
  )

  @core.new_kvector_xy(
    layered_components_max4(
      col_left_width + col_mid_width + col_ns_width + col_right_width,
      size_we.x,
      size_nwe.x,
      size_swe.x,
    ),
    layered_components_max4(
      row_top_height + row_mid_height + row_we_height + row_bottom_height,
      size_ns.y,
      size_wns.y,
      size_ens.y,
    ),
  )
}

///|
pub fn LayeredComponentGroupGraphPlacer::place_components_horizontally(
  self : LayeredComponentGroupGraphPlacer,
  components : Array[LGraph],
  spacing : Double,
) -> @core.KVector {
  let size = @core.new_kvector()
  for component in components {
    self.base.offset_graph(component, size.x, 0.0)
    let component_size = component.get_size()
    size.x += component_size.x + spacing
    size.y = layered_components_max(size.y, component_size.y)
  }
  if size.y > 0.0 {
    size.y += spacing
  }
  size
}

///|
pub fn LayeredComponentGroupGraphPlacer::place_components_vertically(
  self : LayeredComponentGroupGraphPlacer,
  components : Array[LGraph],
  spacing : Double,
) -> @core.KVector {
  let size = @core.new_kvector()
  for component in components {
    self.base.offset_graph(component, 0.0, size.y)
    let component_size = component.get_size()
    size.y += component_size.y + spacing
    size.x = layered_components_max(size.x, component_size.x)
  }
  if size.x > 0.0 {
    size.x += spacing
  }
  size
}

///|
pub fn LayeredComponentGroupGraphPlacer::place_components_in_rows(
  self : LayeredComponentGroupGraphPlacer,
  components : Array[LGraph],
  spacing : Double,
) -> @core.KVector {
  if components.is_empty() {
    return @core.new_kvector()
  }

  let mut max_row_width = 0.0
  let mut total_area = 0.0
  for component in components {
    let component_size = component.get_size()
    max_row_width = layered_components_max(max_row_width, component_size.x)
    total_area += component_size.x * component_size.y
  }

  max_row_width = layered_components_max(
    max_row_width,
    total_area.sqrt() * components[0].get_property_double(@core.aspect_ratio),
  )

  let mut xpos = 0.0
  let mut ypos = 0.0
  let mut highest_box = 0.0
  let mut broadest_row = spacing
  for graph in components {
    let size = graph.get_size()
    if xpos + size.x > max_row_width {
      xpos = 0.0
      ypos += highest_box + spacing
      highest_box = 0.0
    }

    self.base.offset_graph(graph, xpos, ypos)
    broadest_row = layered_components_max(broadest_row, xpos + size.x)
    highest_box = layered_components_max(highest_box, size.y)
    xpos += size.x + spacing
  }

  @core.new_kvector_xy(broadest_row + spacing, ypos + highest_box + spacing)
}
