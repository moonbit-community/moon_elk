///|
fn inside_port_label_cell_creator_create_inside_port_label_cell(
  node_context : NodeContext,
  container : StripContainerCell,
  container_area : ContainerArea,
  port_side : PortSide,
) -> Unit {
  let port_label_cell = new_atomic_cell()
  container.set_cell(container_area, Some(port_label_cell))
  node_context.inside_port_label_cells[node_context_port_side_key(port_side)] = port_label_cell
}

///|
fn inside_port_label_cell_creator_setup_north_or_south_port_label_cell(
  node_context : NodeContext,
  port_side : PortSide,
) -> Unit {
  let cell = match
    node_context.inside_port_label_cells.get(
      node_context_port_side_key(port_side),
    ) {
    Some(value) => value
    None => return
  }
  let padding = cell.get_padding()

  match port_side {
    North =>
      if node_context.port_label_spacing_vertical >= 0.0 {
        padding.top = node_context.port_label_spacing_vertical
      }
    South =>
      if node_context.port_label_spacing_vertical >= 0.0 {
        padding.bottom = node_context.port_label_spacing_vertical
      }
    _ => ()
  }

  padding.left = node_context.surrounding_port_margins.left
  padding.right = node_context.surrounding_port_margins.right
}

///|
fn inside_port_label_cell_creator_calculate_width_due_to_labels(
  node_context : NodeContext,
  port_side : PortSide,
) -> Unit {
  let the_appropriate_cell = match
    node_context.inside_port_label_cells.get(
      node_context_port_side_key(port_side),
    ) {
    Some(value) => value
    None => return
  }
  let min_cell_size = the_appropriate_cell.get_minimum_content_area_size()

  for port_context in node_context_get_port_contexts(node_context, port_side) {
    match port_context.port_label_cell {
      Some(port_label_cell) =>
        min_cell_size.x = @cmp.maximum(
          min_cell_size.x,
          port_label_cell.get_minimum_width(),
        )
      None => ()
    }
  }

  if min_cell_size.x > 0.0 {
    match port_side {
      East =>
        the_appropriate_cell.get_padding().right = node_context.port_label_spacing_horizontal
      West =>
        the_appropriate_cell.get_padding().left = node_context.port_label_spacing_horizontal
      _ => ()
    }
  }
}

///|
fn inside_port_label_cell_creator_setup_top_and_bottom_padding(
  node_context : NodeContext,
  port_side : PortSide,
) -> Unit {
  match
    node_context.inside_port_label_cells.get(
      node_context_port_side_key(port_side),
    ) {
    Some(cell) => {
      let padding = cell.get_padding()
      padding.top = node_context.surrounding_port_margins.top
      padding.bottom = node_context.surrounding_port_margins.bottom
    }
    None => ()
  }
}

///|
fn inside_port_label_cell_creator_setup_east_or_west_port_label_cell(
  node_context : NodeContext,
  port_side : PortSide,
) -> Unit {
  if node_context.has_port_label_placement(Inside) {
    inside_port_label_cell_creator_calculate_width_due_to_labels(
      node_context, port_side,
    )
  }
  inside_port_label_cell_creator_setup_top_and_bottom_padding(
    node_context, port_side,
  )
}

///|
pub fn inside_port_label_cell_creator_create_inside_port_label_cells(
  node_context : NodeContext,
) -> Unit {
  inside_port_label_cell_creator_create_inside_port_label_cell(
    node_context,
    node_context.node_container,
    Begin,
    North,
  )
  inside_port_label_cell_creator_create_inside_port_label_cell(
    node_context,
    node_context.node_container,
    End,
    South,
  )
  inside_port_label_cell_creator_create_inside_port_label_cell(
    node_context,
    node_context.node_container_middle_row,
    Begin,
    West,
  )
  inside_port_label_cell_creator_create_inside_port_label_cell(
    node_context,
    node_context.node_container_middle_row,
    End,
    East,
  )

  inside_port_label_cell_creator_setup_north_or_south_port_label_cell(
    node_context,
    North,
  )
  inside_port_label_cell_creator_setup_north_or_south_port_label_cell(
    node_context,
    South,
  )
  inside_port_label_cell_creator_setup_east_or_west_port_label_cell(
    node_context,
    East,
  )
  inside_port_label_cell_creator_setup_east_or_west_port_label_cell(
    node_context,
    West,
  )
}
