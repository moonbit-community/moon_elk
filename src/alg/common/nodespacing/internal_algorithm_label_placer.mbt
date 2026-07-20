///|
fn label_placer_place_horizontal_outer_node_label_container(
  node_context : NodeContext,
  outer_node_labels_overhang : Bool,
  port_side : @core.PortSide,
) -> Unit {
  let node_size = node_context.node_size
  let node_label_container = match
    node_context.outside_node_label_containers.get(
      node_context_port_side_key(port_side),
    ) {
    Some(value) => value
    None => return
  }
  let node_label_container_rect = node_label_container.get_cell_rectangle()

  node_label_container_rect.width = node_label_container.get_minimum_width()
  node_label_container_rect.height = node_label_container.get_minimum_height()
  node_label_container_rect.width = @cmp.maximum(
    node_label_container_rect.width,
    node_size.x,
  )

  if node_label_container_rect.width > node_size.x &&
    !outer_node_labels_overhang {
    node_label_container_rect.width = node_size.x
  }

  node_label_container_rect.x = -(node_label_container_rect.width - node_size.x) /
    2.0

  match port_side {
    North => node_label_container_rect.y = -node_label_container_rect.height
    South => node_label_container_rect.y = node_size.y
    _ => ()
  }

  node_label_container.layout_children_horizontally()
  node_label_container.layout_children_vertically()
}

///|
fn label_placer_place_vertical_outer_node_label_container(
  node_context : NodeContext,
  outer_node_labels_overhang : Bool,
  port_side : @core.PortSide,
) -> Unit {
  let node_size = node_context.node_size
  let node_label_container = match
    node_context.outside_node_label_containers.get(
      node_context_port_side_key(port_side),
    ) {
    Some(value) => value
    None => return
  }
  let node_label_container_rect = node_label_container.get_cell_rectangle()

  node_label_container_rect.width = node_label_container.get_minimum_width()
  node_label_container_rect.height = node_label_container.get_minimum_height()
  node_label_container_rect.height = @cmp.maximum(
    node_label_container_rect.height,
    node_size.y,
  )

  if node_label_container_rect.height > node_size.y &&
    !outer_node_labels_overhang {
    node_label_container_rect.height = node_size.y
  }

  node_label_container_rect.y = -(node_label_container_rect.height - node_size.y) /
    2.0
  match port_side {
    West => node_label_container_rect.x = -node_label_container_rect.width
    East => node_label_container_rect.x = node_size.x
    _ => ()
  }

  node_label_container.layout_children_horizontally()
  node_label_container.layout_children_vertically()
}

///|
fn label_placer_place_outer_node_label_containers(
  node_context : NodeContext,
) -> Unit {
  let outer_node_labels_overhang = node_context.has_size_option(
    OutsideNodeLabelsOverhang,
  )

  label_placer_place_horizontal_outer_node_label_container(
    node_context,
    outer_node_labels_overhang,
    North,
  )
  label_placer_place_horizontal_outer_node_label_container(
    node_context,
    outer_node_labels_overhang,
    South,
  )
  label_placer_place_vertical_outer_node_label_container(
    node_context,
    outer_node_labels_overhang,
    East,
  )
  label_placer_place_vertical_outer_node_label_container(
    node_context,
    outer_node_labels_overhang,
    West,
  )
}

///|
pub fn label_placer_place_labels(node_context : NodeContext) -> Unit {
  label_placer_place_outer_node_label_containers(node_context)

  for entry in node_context.node_label_cells.to_array() {
    let (_, label_cell) = entry
    label_cell.apply_label_layout()
  }

  for port_context in node_context_get_all_port_contexts(node_context) {
    match port_context.port_label_cell {
      Some(label_cell) => label_cell.apply_label_layout()
      None => ()
    }
  }
}
