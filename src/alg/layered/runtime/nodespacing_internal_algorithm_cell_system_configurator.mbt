///|
pub fn cell_system_configurator_configure_cell_system_size_contributions(
  node_context : NodeContext,
) -> Unit {
  if node_context.size_constraints.is_empty() {
    return
  }

  if node_context.has_size_constraint(Ports) {
    match
      node_context.inside_port_label_cells.get(
        node_context_port_side_key(North),
      ) {
      Some(cell) => cell.set_contributes_to_minimum_width(true)
      None => ()
    }
    match
      node_context.inside_port_label_cells.get(
        node_context_port_side_key(South),
      ) {
      Some(cell) => cell.set_contributes_to_minimum_width(true)
      None => ()
    }

    let free_port_placement = !node_context_port_constraints_equals(
        node_context.port_constraints,
        FixedRatio,
      ) &&
      !node_context_port_constraints_equals(
        node_context.port_constraints,
        FixedPos,
      )
    match
      node_context.inside_port_label_cells.get(node_context_port_side_key(East)) {
      Some(cell) => cell.set_contributes_to_minimum_height(free_port_placement)
      None => ()
    }
    match
      node_context.inside_port_label_cells.get(node_context_port_side_key(West)) {
      Some(cell) => cell.set_contributes_to_minimum_height(free_port_placement)
      None => ()
    }

    node_context.node_container_middle_row.set_contributes_to_minimum_height(
      free_port_placement,
    )

    if node_context.has_size_constraint(PortLabels) {
      match
        node_context.inside_port_label_cells.get(
          node_context_port_side_key(North),
        ) {
        Some(cell) => cell.set_contributes_to_minimum_height(true)
        None => ()
      }
      match
        node_context.inside_port_label_cells.get(
          node_context_port_side_key(South),
        ) {
        Some(cell) => cell.set_contributes_to_minimum_height(true)
        None => ()
      }
      match
        node_context.inside_port_label_cells.get(
          node_context_port_side_key(East),
        ) {
        Some(cell) => cell.set_contributes_to_minimum_width(true)
        None => ()
      }
      match
        node_context.inside_port_label_cells.get(
          node_context_port_side_key(West),
        ) {
        Some(cell) => cell.set_contributes_to_minimum_width(true)
        None => ()
      }
      node_context.node_container_middle_row.set_contributes_to_minimum_width(
        true,
      )
    }
  }

  if node_context.has_size_constraint(NodeLabels) {
    node_context.inside_node_label_container.set_contributes_to_minimum_height(
      true,
    )
    node_context.inside_node_label_container.set_contributes_to_minimum_width(
      true,
    )
    node_context.node_container_middle_row.set_contributes_to_minimum_height(
      true,
    )
    node_context.node_container_middle_row.set_contributes_to_minimum_width(
      true,
    )

    let overhang = node_context.has_size_option(OutsideNodeLabelsOverhang)
    for location in node_label_location_values() {
      match
        node_context.node_label_cells.get(
          node_context_node_label_location_key(location),
        ) {
        Some(label_cell) =>
          if location.is_inside_location() {
            label_cell.set_contributes_to_minimum_height(true)
            label_cell.set_contributes_to_minimum_width(true)
          } else {
            label_cell.set_contributes_to_minimum_height(!overhang)
            label_cell.set_contributes_to_minimum_width(!overhang)
          }
        None => ()
      }
    }
  }

  if node_context.has_size_constraint(MinimumSize) &&
    node_context.has_size_option(MinimumSizeAccountsForPadding) {
    node_context.node_container_middle_row.set_contributes_to_minimum_height(
      true,
    )
    node_context.node_container_middle_row.set_contributes_to_minimum_width(
      true,
    )

    if !node_context.inside_node_label_container.is_contributing_to_minimum_height() {
      node_context.inside_node_label_container.set_contributes_to_minimum_height(
        true,
      )
      node_context.inside_node_label_container.set_contributes_to_minimum_width(
        true,
      )
      grid_container_cell_set_only_center_cell_contributes_to_minimum_size(
        node_context.inside_node_label_container,
        true,
      )
    }
  }
}

///|
pub fn cell_system_configurator_update_vertical_inside_port_label_cell_padding(
  node_context : NodeContext,
) -> Unit {
  if node_context_port_constraints_equals(
      node_context.port_constraints,
      FixedRatio,
    ) ||
    node_context_port_constraints_equals(
      node_context.port_constraints,
      FixedPos,
    ) {
    return
  }

  let north_cell = match
    node_context.inside_port_label_cells.get(node_context_port_side_key(North)) {
    Some(value) => value
    None => return
  }
  let south_cell = match
    node_context.inside_port_label_cells.get(node_context_port_side_key(South)) {
    Some(value) => value
    None => return
  }
  let east_cell = match
    node_context.inside_port_label_cells.get(node_context_port_side_key(East)) {
    Some(value) => value
    None => return
  }
  let west_cell = match
    node_context.inside_port_label_cells.get(node_context_port_side_key(West)) {
    Some(value) => value
    None => return
  }

  let top_border_offset = node_context.node_container.get_padding().top +
    north_cell.get_minimum_height() +
    node_context.label_cell_spacing
  let bottom_border_offset = node_context.node_container.get_padding().bottom +
    south_cell.get_minimum_height() +
    node_context.label_cell_spacing

  let mut top_padding = @cmp.maximum(
    0.0,
    east_cell.get_padding().top - top_border_offset,
  )
  top_padding = @cmp.maximum(
    top_padding,
    west_cell.get_padding().top - top_border_offset,
  )

  let mut bottom_padding = @cmp.maximum(
    0.0,
    east_cell.get_padding().bottom - bottom_border_offset,
  )
  bottom_padding = @cmp.maximum(
    bottom_padding,
    west_cell.get_padding().bottom - bottom_border_offset,
  )

  east_cell.get_padding().top = top_padding
  west_cell.get_padding().top = top_padding
  east_cell.get_padding().bottom = bottom_padding
  west_cell.get_padding().bottom = bottom_padding
}
