///|
fn port_label_placement_calculator_port_has_labels(
  port_context : PortContext,
) -> Bool {
  match port_context.port_label_cell {
    Some(port_label_cell) => port_label_cell.has_labels()
    None => false
  }
}

///|
fn port_label_placement_calculator_side_is_north_or_south(
  port_side : @core.PortSide,
) -> Bool {
  match port_side {
    North => true
    South => true
    _ => false
  }
}

///|
fn port_label_placement_calculator_side_is_east_or_west(
  port_side : @core.PortSide,
) -> Bool {
  match port_side {
    East => true
    West => true
    _ => false
  }
}

///|
fn port_label_placement_calculator_constrained_placement(
  node_context : NodeContext,
) -> Bool {
  !node_context.has_size_constraint(PortLabels) ||
  node_context_port_constraints_equals(node_context.port_constraints, FixedPos)
}

///|
fn port_label_placement_calculator_port_label_border_offset_for_port_side(
  node_context : NodeContext,
  port_side : @core.PortSide,
) -> Double {
  match port_side {
    North =>
      node_context.node_container.get_padding().top +
      node_context.port_label_spacing_vertical
    South =>
      node_context.node_container.get_padding().bottom +
      node_context.port_label_spacing_vertical
    East =>
      node_context.node_container.get_padding().right +
      node_context.port_label_spacing_horizontal
    West =>
      node_context.node_container.get_padding().left +
      node_context.port_label_spacing_horizontal
    SideUndefined => 0.0
  }
}

///|
fn port_label_placement_calculator_simple_inside_port_label_placement(
  node_context : NodeContext,
  port_side : @core.PortSide,
) -> Unit {
  let mut inside_north_or_south_port_label_area_height = 0.0
  let label_border_offset = port_label_placement_calculator_port_label_border_offset_for_port_side(
    node_context, port_side,
  )
  let port_label_spacing_horizontal = node_context.port_label_spacing_horizontal
  let port_label_spacing_vertical = node_context.port_label_spacing_vertical

  for port_context in node_context_get_port_contexts(node_context, port_side) {
    if !port_label_placement_calculator_port_has_labels(port_context) {
      continue
    }

    let port_size = port_context.port.get_size()
    let port_border_offset = if port_context.port.has_property_double(
        nodespacing_port_border_offset_property,
      ) {
      port_context.port.get_property_double(
        nodespacing_port_border_offset_property,
      )
    } else {
      0.0
    }

    let port_label_cell = match port_context.port_label_cell {
      Some(value) => value
      None => continue
    }
    let port_label_cell_rect = port_label_cell.get_cell_rectangle()
    port_label_cell_rect.width = port_label_cell.get_minimum_width()
    port_label_cell_rect.height = port_label_cell.get_minimum_height()

    match port_side {
      North => {
        port_label_cell_rect.x = if port_context.labels_next_to_port {
          (port_size.x - port_label_cell_rect.width) / 2.0
        } else {
          port_size.x + port_label_spacing_horizontal
        }
        port_label_cell_rect.y = port_size.y +
          port_border_offset +
          label_border_offset
        ignore(
          port_label_cell.set_horizontal_alignment(
            HorizontalLabelAlignment::Center,
          ),
        )
        ignore(
          port_label_cell.set_vertical_alignment(VerticalLabelAlignment::Top),
        )
      }
      South => {
        port_label_cell_rect.x = if port_context.labels_next_to_port {
          (port_size.x - port_label_cell_rect.width) / 2.0
        } else {
          port_size.x + port_label_spacing_horizontal
        }
        port_label_cell_rect.y = -port_border_offset -
          label_border_offset -
          port_label_cell_rect.height
        ignore(
          port_label_cell.set_horizontal_alignment(
            HorizontalLabelAlignment::Center,
          ),
        )
        ignore(
          port_label_cell.set_vertical_alignment(VerticalLabelAlignment::Bottom),
        )
      }
      East => {
        port_label_cell_rect.x = -port_border_offset -
          label_border_offset -
          port_label_cell_rect.width
        if port_context.labels_next_to_port {
          let single_label_height = if node_context.port_labels_treat_as_group {
            port_label_cell_rect.height
          } else {
            @graph.label_height(port_label_cell.get_labels()[0])
          }
          port_label_cell_rect.y = (port_size.y - single_label_height) / 2.0
        } else {
          port_label_cell_rect.y = port_size.y + port_label_spacing_vertical
        }
        ignore(
          port_label_cell.set_horizontal_alignment(
            HorizontalLabelAlignment::Right,
          ),
        )
        ignore(
          port_label_cell.set_vertical_alignment(VerticalLabelAlignment::Center),
        )
      }
      West => {
        port_label_cell_rect.x = port_size.x +
          port_border_offset +
          label_border_offset
        if port_context.labels_next_to_port {
          let single_label_height = if node_context.port_labels_treat_as_group {
            port_label_cell_rect.height
          } else {
            @graph.label_height(port_label_cell.get_labels()[0])
          }
          port_label_cell_rect.y = (port_size.y - single_label_height) / 2.0
        } else {
          port_label_cell_rect.y = port_size.y + port_label_spacing_vertical
        }
        ignore(
          port_label_cell.set_horizontal_alignment(
            HorizontalLabelAlignment::Left,
          ),
        )
        ignore(
          port_label_cell.set_vertical_alignment(VerticalLabelAlignment::Center),
        )
      }
      SideUndefined => ()
    }

    if port_label_placement_calculator_side_is_north_or_south(port_side) {
      inside_north_or_south_port_label_area_height = @cmp.maximum(
        inside_north_or_south_port_label_area_height,
        port_label_cell_rect.height,
      )
    }
  }

  if inside_north_or_south_port_label_area_height > 0.0 {
    match
      node_context.inside_port_label_cells.get(
        node_context_port_side_key(port_side),
      ) {
      Some(cell) =>
        cell.get_minimum_content_area_size().y = inside_north_or_south_port_label_area_height
      None => ()
    }
  }
}

///|
fn port_label_placement_calculator_center_port_label(
  port_label_cell_rect : @core.ElkRectangle,
  port_position : @core.KVector,
  port_size : @core.KVector,
  min_x : Double,
  max_x : Double,
) -> Unit {
  port_label_cell_rect.x = port_position.x -
    (port_label_cell_rect.width - port_size.x) / 2.0

  let actual_min_x = @cmp.minimum(min_x, port_position.x)
  let actual_max_x = @cmp.maximum(max_x, port_position.x + port_size.x)

  if port_label_cell_rect.x < actual_min_x {
    port_label_cell_rect.x = actual_min_x
  } else if port_label_cell_rect.x + port_label_cell_rect.width > actual_max_x {
    port_label_cell_rect.x = actual_max_x - port_label_cell_rect.width
  }
}

///|
fn port_label_placement_calculator_constrained_inside_port_label_placement(
  node_context : NodeContext,
  port_side : @core.PortSide,
) -> Unit {
  if port_label_placement_calculator_side_is_east_or_west(port_side) {
    port_label_placement_calculator_simple_inside_port_label_placement(
      node_context, port_side,
    )
    return
  }

  let overlap_removal_direction = if port_side is North {
    @core.Downward
  } else {
    @core.Upward
  }
  let vertical_label_alignment = if port_side is North {
    VerticalLabelAlignment::Top
  } else {
    VerticalLabelAlignment::Bottom
  }

  let inside_port_label_container = match
    node_context.inside_port_label_cells.get(
      node_context_port_side_key(port_side),
    ) {
    Some(value) => value
    None => return
  }
  let label_container_rect = inside_port_label_container.get_cell_rectangle()
  let left_border = label_container_rect.x +
    @cmp.maximum(
      inside_port_label_container.get_padding().left,
      @cmp.maximum(
        node_context.surrounding_port_margins.left,
        node_context.node_label_spacing,
      ),
    )
  let right_border = label_container_rect.x +
    label_container_rect.width -
    @cmp.maximum(
      inside_port_label_container.get_padding().right,
      @cmp.maximum(
        node_context.surrounding_port_margins.right,
        node_context.node_label_spacing,
      ),
    )

  let overlap_remover = create_rectangle_strip_overlap_remover_for_direction(
    overlap_removal_direction,
  ).with_gap(
    node_context.port_label_spacing_horizontal,
    node_context.port_label_spacing_vertical,
  )

  let mut start_coordinate = if port_side is North {
    -@double.infinity
  } else {
    @double.infinity
  }
  for port_context in node_context_get_port_contexts(node_context, port_side) {
    if !port_label_placement_calculator_port_has_labels(port_context) {
      continue
    }

    let port_size = port_context.port.get_size()
    let port_position = port_context.port_position
    let port_label_cell = match port_context.port_label_cell {
      Some(value) => value
      None => continue
    }
    let port_label_cell_rect = port_label_cell.get_cell_rectangle()

    port_label_cell_rect.width = port_label_cell.get_minimum_width()
    port_label_cell_rect.height = port_label_cell.get_minimum_height()
    ignore(port_label_cell.set_vertical_alignment(vertical_label_alignment))
    ignore(
      port_label_cell.set_horizontal_alignment(HorizontalLabelAlignment::Right),
    )

    port_label_placement_calculator_center_port_label(
      port_label_cell_rect, port_position, port_size, left_border, right_border,
    )
    ignore(overlap_remover.add_rectangle(port_label_cell_rect))

    start_coordinate = if port_side is North {
      @cmp.maximum(start_coordinate, port_position.y + port_size.y)
    } else {
      @cmp.minimum(start_coordinate, port_position.y)
    }
  }
  start_coordinate += if port_side is North {
    node_context.port_label_spacing_vertical
  } else {
    -node_context.port_label_spacing_vertical
  }

  let strip_height = overlap_remover
    .with_start_coordinate(start_coordinate)
    .remove_overlaps()

  if strip_height > 0.0 {
    match
      node_context.inside_port_label_cells.get(
        node_context_port_side_key(port_side),
      ) {
      Some(cell) => cell.get_minimum_content_area_size().y = strip_height
      None => ()
    }
  }

  for port_context in node_context_get_port_contexts(node_context, port_side) {
    if !port_label_placement_calculator_port_has_labels(port_context) {
      continue
    }
    let port_label_cell = match port_context.port_label_cell {
      Some(value) => value
      None => continue
    }
    let port_label_cell_rect = port_label_cell.get_cell_rectangle()
    port_label_cell_rect.x -= port_context.port_position.x
    port_label_cell_rect.y -= port_context.port_position.y
  }
}

///|
fn port_label_placement_calculator_simple_outside_port_label_placement(
  node_context : NodeContext,
  port_side : @core.PortSide,
) -> Unit {
  let mut place_first_port_differently = node_label_and_size_utilities_is_first_outside_port_label_placed_differently(
    node_context, port_side,
  )
  let always_above = node_context.has_port_label_placement(AlwaysOtherSameSide)

  for port_context in node_context_get_port_contexts(node_context, port_side) {
    if !port_label_placement_calculator_port_has_labels(port_context) {
      continue
    }

    let port_size = port_context.port.get_size()
    let port_label_cell = match port_context.port_label_cell {
      Some(value) => value
      None => continue
    }
    let port_label_cell_rect = port_label_cell.get_cell_rectangle()
    port_label_cell_rect.width = port_label_cell.get_minimum_width()
    port_label_cell_rect.height = port_label_cell.get_minimum_height()

    match port_side {
      North => {
        if port_context.labels_next_to_port {
          port_label_cell_rect.x = (port_size.x - port_label_cell_rect.width) /
            2.0
          ignore(
            port_label_cell.set_horizontal_alignment(
              HorizontalLabelAlignment::Center,
            ),
          )
        } else if place_first_port_differently || always_above {
          port_label_cell_rect.x = -port_label_cell_rect.width -
            node_context.port_label_spacing_horizontal
          ignore(
            port_label_cell.set_horizontal_alignment(
              HorizontalLabelAlignment::Right,
            ),
          )
        } else {
          port_label_cell_rect.x = port_size.x +
            node_context.port_label_spacing_horizontal
          ignore(
            port_label_cell.set_horizontal_alignment(
              HorizontalLabelAlignment::Left,
            ),
          )
        }
        port_label_cell_rect.y = -port_label_cell_rect.height -
          node_context.port_label_spacing_vertical
        ignore(
          port_label_cell.set_vertical_alignment(VerticalLabelAlignment::Bottom),
        )
      }
      South => {
        if port_context.labels_next_to_port {
          port_label_cell_rect.x = (port_size.x - port_label_cell_rect.width) /
            2.0
          ignore(
            port_label_cell.set_horizontal_alignment(
              HorizontalLabelAlignment::Center,
            ),
          )
        } else if place_first_port_differently || always_above {
          port_label_cell_rect.x = -port_label_cell_rect.width -
            node_context.port_label_spacing_horizontal
          ignore(
            port_label_cell.set_horizontal_alignment(
              HorizontalLabelAlignment::Right,
            ),
          )
        } else {
          port_label_cell_rect.x = port_size.x +
            node_context.port_label_spacing_horizontal
          ignore(
            port_label_cell.set_horizontal_alignment(
              HorizontalLabelAlignment::Left,
            ),
          )
        }
        port_label_cell_rect.y = port_size.y +
          node_context.port_label_spacing_vertical
        ignore(
          port_label_cell.set_vertical_alignment(VerticalLabelAlignment::Top),
        )
      }
      East => {
        if port_context.labels_next_to_port {
          let single_label_height = if node_context.port_labels_treat_as_group {
            port_label_cell_rect.height
          } else {
            @graph.label_height(port_label_cell.get_labels()[0])
          }
          port_label_cell_rect.y = (port_size.y - single_label_height) / 2.0
          ignore(
            port_label_cell.set_vertical_alignment(
              VerticalLabelAlignment::Center,
            ),
          )
        } else if place_first_port_differently || always_above {
          port_label_cell_rect.y = -port_label_cell_rect.height -
            node_context.port_label_spacing_vertical
          ignore(
            port_label_cell.set_vertical_alignment(
              VerticalLabelAlignment::Bottom,
            ),
          )
        } else {
          port_label_cell_rect.y = port_size.y +
            node_context.port_label_spacing_vertical
          ignore(
            port_label_cell.set_vertical_alignment(VerticalLabelAlignment::Top),
          )
        }
        port_label_cell_rect.x = port_size.x +
          node_context.port_label_spacing_horizontal
        ignore(
          port_label_cell.set_horizontal_alignment(
            HorizontalLabelAlignment::Left,
          ),
        )
      }
      West => {
        if port_context.labels_next_to_port {
          let single_label_height = if node_context.port_labels_treat_as_group {
            port_label_cell_rect.height
          } else {
            @graph.label_height(port_label_cell.get_labels()[0])
          }
          port_label_cell_rect.y = (port_size.y - single_label_height) / 2.0
          ignore(
            port_label_cell.set_vertical_alignment(
              VerticalLabelAlignment::Center,
            ),
          )
        } else if place_first_port_differently || always_above {
          port_label_cell_rect.y = -port_label_cell_rect.height -
            node_context.port_label_spacing_vertical
          ignore(
            port_label_cell.set_vertical_alignment(
              VerticalLabelAlignment::Bottom,
            ),
          )
        } else {
          port_label_cell_rect.y = port_size.y +
            node_context.port_label_spacing_vertical
          ignore(
            port_label_cell.set_vertical_alignment(VerticalLabelAlignment::Top),
          )
        }
        port_label_cell_rect.x = -port_label_cell_rect.width -
          node_context.port_label_spacing_horizontal
        ignore(
          port_label_cell.set_horizontal_alignment(
            HorizontalLabelAlignment::Right,
          ),
        )
      }
      SideUndefined => ()
    }

    place_first_port_differently = false
  }
}

///|
fn port_label_placement_calculator_constrained_outside_port_label_placement(
  node_context : NodeContext,
  port_side : @core.PortSide,
) -> Unit {
  let port_contexts = node_context_get_port_contexts(node_context, port_side)

  if port_contexts.length() <= 2 ||
    port_label_placement_calculator_side_is_east_or_west(port_side) {
    port_label_placement_calculator_simple_outside_port_label_placement(
      node_context, port_side,
    )
    return
  }

  let mut port_with_special_needs = node_context.has_port_label_placement(
    SpaceEfficient,
  )
  let overlap_removal_direction = if port_side is North {
    @core.Upward
  } else {
    @core.Downward
  }
  let vertical_label_alignment = if port_side is North {
    VerticalLabelAlignment::Bottom
  } else {
    VerticalLabelAlignment::Top
  }

  let overlap_remover = create_rectangle_strip_overlap_remover_for_direction(
    overlap_removal_direction,
  ).with_gap(
    node_context.port_label_spacing_vertical,
    node_context.port_label_spacing_horizontal,
  )

  let mut start_coordinate = if port_side is North {
    @double.infinity
  } else {
    -@double.infinity
  }
  for port_context in port_contexts {
    if !port_label_placement_calculator_port_has_labels(port_context) {
      continue
    }

    let port_size = port_context.port.get_size()
    let port_position = port_context.port_position
    let port_label_cell = match port_context.port_label_cell {
      Some(value) => value
      None => continue
    }
    let port_label_cell_rect = port_label_cell.get_cell_rectangle()

    port_label_cell_rect.width = port_label_cell.get_minimum_width()
    port_label_cell_rect.height = port_label_cell.get_minimum_height()
    if port_with_special_needs {
      port_label_cell_rect.x = port_position.x -
        port_label_cell.get_minimum_width() -
        node_context.port_label_spacing_horizontal
      port_with_special_needs = false
    } else {
      port_label_cell_rect.x = port_position.x +
        port_size.x +
        node_context.port_label_spacing_horizontal
    }
    ignore(port_label_cell.set_vertical_alignment(vertical_label_alignment))
    ignore(
      port_label_cell.set_horizontal_alignment(HorizontalLabelAlignment::Right),
    )

    ignore(overlap_remover.add_rectangle(port_label_cell_rect))
    start_coordinate = if port_side is North {
      @cmp.minimum(start_coordinate, port_position.y)
    } else {
      @cmp.maximum(start_coordinate, port_position.y + port_size.y)
    }
  }
  start_coordinate += if port_side is North {
    -node_context.port_label_spacing_vertical
  } else {
    node_context.port_label_spacing_vertical
  }

  ignore(
    overlap_remover.with_start_coordinate(start_coordinate).remove_overlaps(),
  )

  for port_context in node_context_get_port_contexts(node_context, port_side) {
    if !port_label_placement_calculator_port_has_labels(port_context) {
      continue
    }
    let port_label_cell = match port_context.port_label_cell {
      Some(value) => value
      None => continue
    }
    let port_label_cell_rect = port_label_cell.get_cell_rectangle()
    port_label_cell_rect.x -= port_context.port_position.x
    port_label_cell_rect.y -= port_context.port_position.y
  }
}

///|
fn port_label_placement_calculator_place_port_labels(
  node_context : NodeContext,
  port_side : @core.PortSide,
) -> Unit {
  let constrained_placement = port_label_placement_calculator_constrained_placement(
    node_context,
  )
  if node_context.has_port_label_placement(Inside) {
    if constrained_placement {
      port_label_placement_calculator_constrained_inside_port_label_placement(
        node_context, port_side,
      )
    } else {
      port_label_placement_calculator_simple_inside_port_label_placement(
        node_context, port_side,
      )
    }
  } else if node_context.has_port_label_placement(Outside) {
    if constrained_placement {
      port_label_placement_calculator_constrained_outside_port_label_placement(
        node_context, port_side,
      )
    } else {
      port_label_placement_calculator_simple_outside_port_label_placement(
        node_context, port_side,
      )
    }
  }
}

///|
pub fn port_label_placement_calculator_place_horizontal_port_labels(
  node_context : NodeContext,
) -> Unit {
  port_label_placement_calculator_place_port_labels(node_context, North)
  port_label_placement_calculator_place_port_labels(node_context, South)
}

///|
pub fn port_label_placement_calculator_place_vertical_port_labels(
  node_context : NodeContext,
) -> Unit {
  port_label_placement_calculator_place_port_labels(node_context, East)
  port_label_placement_calculator_place_port_labels(node_context, West)
}
