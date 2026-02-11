///|
fn layered_group_model_order_contains_side(
  sides : Array[PortSide],
  expected : PortSide,
) -> Bool {
  for side in sides {
    if port_side_to_string(side) == port_side_to_string(expected) {
      return true
    }
  }
  false
}

///|
pub struct LayeredComponentGroupModelOrderGraphPlacer {
  base : LayeredAbstractGraphPlacer
  helper : LayeredComponentGroupGraphPlacer
  component_groups : Array[ModelOrderComponentGroup]
}

///|
pub fn new_layered_component_group_model_order_graph_placer() -> LayeredComponentGroupModelOrderGraphPlacer {
  {
    base: new_layered_abstract_graph_placer(),
    helper: new_layered_component_group_graph_placer(),
    component_groups: [],
  }
}

///|
pub fn LayeredComponentGroupModelOrderGraphPlacer::combine(
  self : LayeredComponentGroupModelOrderGraphPlacer,
  components : Array[LGraph],
  target : LGraph,
) -> Unit {
  self.component_groups.clear()

  if components.is_empty() {
    target.set_size_xy(0.0, 0.0)
    return
  }

  let first_component = components[0]
  target.copy_properties(first_component)

  for component in components {
    self.add_component(component)
  }

  let space_blocked_by_south_edges = new_kvector()
  let space_blocked_by_components = new_kvector()
  let offset = new_kvector()
  let max_size = new_kvector()
  let component_spacing = first_component.get_property_double(
    spacing_component_component,
  )
  let direction = target.get_property_direction(layered_components_direction)

  for group in self.component_groups {
    if direction.is_horizontal() {
      offset.x = space_blocked_by_south_edges.x
      for sides in group.get_port_sides() {
        if layered_group_model_order_contains_side(sides, North) {
          offset.x = space_blocked_by_components.x
          break
        }
      }
    } else if direction.is_vertical() {
      offset.y = space_blocked_by_south_edges.y
      for sides in group.get_port_sides() {
        if layered_group_model_order_contains_side(sides, West) {
          offset.y = space_blocked_by_components.y
          break
        }
      }
    }

    let group_size = self.place_components(group, component_spacing)
    self.base.offset_graphs(group.get_components(), offset.x, offset.y)

    if direction.is_horizontal() {
      space_blocked_by_components.x = offset.x + group_size.x
      max_size.x = layered_components_max(
        max_size.x,
        space_blocked_by_components.x,
      )
      for sides in group.get_port_sides() {
        if layered_group_model_order_contains_side(sides, South) {
          space_blocked_by_south_edges.x = offset.x + group_size.x
          break
        }
      }

      space_blocked_by_components.y = offset.y + group_size.y
      offset.y = space_blocked_by_components.y
      max_size.y = layered_components_max(max_size.y, offset.y)
    } else if direction.is_vertical() {
      space_blocked_by_components.y = offset.y + group_size.y
      max_size.y = layered_components_max(
        max_size.y,
        space_blocked_by_components.y,
      )
      for sides in group.get_port_sides() {
        if layered_group_model_order_contains_side(sides, East) {
          space_blocked_by_south_edges.y = offset.y + group_size.y
          break
        }
      }

      space_blocked_by_components.x = offset.x + group_size.x
      offset.x = space_blocked_by_components.x
      max_size.x = layered_components_max(max_size.x, offset.x)
    }
  }

  target.set_size_xy(
    max_size.x - component_spacing,
    max_size.y - component_spacing,
  )

  if first_component.get_property_bool(
      layered_components_compaction_connected_components,
    ) &&
    first_component.get_property_string(layered_components_edge_routing) ==
    "ORTHOGONAL" {
    for graph in components {
      let graph_offset = graph.get_offset()
      self.base.offset_graph(graph, graph_offset.x, graph_offset.y)
    }

    let compactor = new_layered_components_compactor()
    compactor.compact(components, target.get_size(), component_spacing)

    for graph in components {
      let compacted_offset = compactor.get_offset()
      graph.set_offset_xy(compacted_offset.x, compacted_offset.y)
    }

    let compacted_size = compactor.get_graph_size()
    target.set_size_xy(compacted_size.x, compacted_size.y)
  }

  for group in self.component_groups {
    self.base.move_graphs(target, group.get_components(), 0.0, 0.0)
  }
}

///|
pub fn LayeredComponentGroupModelOrderGraphPlacer::add_component(
  self : LayeredComponentGroupModelOrderGraphPlacer,
  component : LGraph,
) -> Unit {
  if self.component_groups.length() > 0 {
    let last_group = self.component_groups[self.component_groups.length() - 1]
    if last_group.add(component) {
      return
    }
  }
  self.component_groups.push(
    new_model_order_component_group_with_component(component),
  )
}

///|
pub fn LayeredComponentGroupModelOrderGraphPlacer::place_components(
  self : LayeredComponentGroupModelOrderGraphPlacer,
  group : ModelOrderComponentGroup,
  spacing : Double,
) -> KVector {
  let size_c = self.helper.place_components_in_rows(
    group.get_components_with_connections(sides_none),
    spacing,
  )
  let size_n = self.helper.place_components_horizontally(
    group.get_components_with_connections(sides_north),
    spacing,
  )
  let size_s = self.helper.place_components_horizontally(
    group.get_components_with_connections(sides_south),
    spacing,
  )
  let size_w = self.helper.place_components_vertically(
    group.get_components_with_connections(sides_west),
    spacing,
  )
  let size_e = self.helper.place_components_vertically(
    group.get_components_with_connections(sides_east),
    spacing,
  )
  let size_nw = self.helper.place_components_horizontally(
    group.get_components_with_connections(sides_north_west),
    spacing,
  )
  let size_ne = self.helper.place_components_horizontally(
    group.get_components_with_connections(sides_north_east),
    spacing,
  )
  let size_sw = self.helper.place_components_horizontally(
    group.get_components_with_connections(sides_south_west),
    spacing,
  )
  let size_se = self.helper.place_components_horizontally(
    group.get_components_with_connections(sides_east_south),
    spacing,
  )
  let size_we = self.helper.place_components_vertically(
    group.get_components_with_connections(sides_east_west),
    spacing,
  )
  let size_ns = self.helper.place_components_horizontally(
    group.get_components_with_connections(sides_north_south),
    spacing,
  )
  let size_nwe = self.helper.place_components_horizontally(
    group.get_components_with_connections(sides_north_east_west),
    spacing,
  )
  let size_swe = self.helper.place_components_horizontally(
    group.get_components_with_connections(sides_east_south_west),
    spacing,
  )
  let size_wns = self.helper.place_components_vertically(
    group.get_components_with_connections(sides_north_south_west),
    spacing,
  )
  let size_ens = self.helper.place_components_vertically(
    group.get_components_with_connections(sides_north_east_south),
    spacing,
  )
  let size_nesw = self.helper.place_components_horizontally(
    group.get_components_with_connections(sides_north_east_south_west),
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
    group.get_components_with_connections(sides_none),
    col_left_width + col_ns_width,
    row_top_height + row_we_height,
  )
  self.base.offset_graphs(
    group.get_components_with_connections(sides_north_east_south_west),
    col_left_width + col_ns_width,
    row_top_height + row_we_height,
  )
  self.base.offset_graphs(
    group.get_components_with_connections(sides_north),
    col_left_width + col_ns_width,
    0.0,
  )
  self.base.offset_graphs(
    group.get_components_with_connections(sides_south),
    col_left_width + col_ns_width,
    row_top_height + row_we_height + row_mid_height,
  )
  self.base.offset_graphs(
    group.get_components_with_connections(sides_west),
    0.0,
    row_top_height + row_we_height,
  )
  self.base.offset_graphs(
    group.get_components_with_connections(sides_east),
    col_left_width + col_ns_width + col_mid_width,
    row_top_height + row_we_height,
  )
  self.base.offset_graphs(
    group.get_components_with_connections(sides_north_east),
    col_left_width + col_ns_width + col_mid_width,
    0.0,
  )
  self.base.offset_graphs(
    group.get_components_with_connections(sides_south_west),
    0.0,
    row_top_height + row_we_height + row_mid_height,
  )
  self.base.offset_graphs(
    group.get_components_with_connections(sides_east_south),
    col_left_width + col_ns_width + col_mid_width,
    row_top_height + row_we_height + row_mid_height,
  )
  self.base.offset_graphs(
    group.get_components_with_connections(sides_east_west),
    0.0,
    row_top_height,
  )
  self.base.offset_graphs(
    group.get_components_with_connections(sides_north_south),
    col_left_width,
    0.0,
  )
  self.base.offset_graphs(
    group.get_components_with_connections(sides_east_south_west),
    0.0,
    row_top_height + row_we_height + row_mid_height,
  )
  self.base.offset_graphs(
    group.get_components_with_connections(sides_north_east_south),
    col_left_width + col_ns_width + col_mid_width,
    0.0,
  )

  new_kvector_xy(
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
