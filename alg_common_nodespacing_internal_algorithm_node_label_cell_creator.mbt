///|
fn node_label_cell_creator_create_node_label_cell_containers(
  node_context : NodeContext,
  only_inside : Bool,
) -> Unit {
  let symmetry = !node_context.has_size_option(Asymmetrical)
  let tabular_node_labels = node_context.has_size_option(ForceTabularNodeLabels)

  node_context.inside_node_label_container = new_grid_container_cell(
    tabular_node_labels,
    symmetry,
    node_context.label_cell_spacing,
  )
  ignore(
    node_context.inside_node_label_container
    .get_padding()
    .copy(node_context.node_labels_padding),
  )
  node_context.node_container_middle_row.set_cell(
    Center,
    Some(node_context.inside_node_label_container),
  )

  if only_inside {
    return
  }

  let north_container = new_strip_container_cell(
    Horizontal,
    symmetry,
    node_context.label_cell_spacing,
  )
  north_container.get_padding().bottom = node_context.node_label_spacing
  node_context.outside_node_label_containers[node_context_port_side_key(North)] = north_container

  let south_container = new_strip_container_cell(
    Horizontal,
    symmetry,
    node_context.label_cell_spacing,
  )
  south_container.get_padding().top = node_context.node_label_spacing
  node_context.outside_node_label_containers[node_context_port_side_key(South)] = south_container

  let west_container = new_strip_container_cell(
    Vertical,
    symmetry,
    node_context.label_cell_spacing,
  )
  west_container.get_padding().right = node_context.node_label_spacing
  node_context.outside_node_label_containers[node_context_port_side_key(West)] = west_container

  let east_container = new_strip_container_cell(
    Vertical,
    symmetry,
    node_context.label_cell_spacing,
  )
  east_container.get_padding().left = node_context.node_label_spacing
  node_context.outside_node_label_containers[node_context_port_side_key(East)] = east_container
}

///|
pub fn node_label_cell_creator_create_node_label_cells(
  node_context : NodeContext,
  only_inside : Bool,
  horizontal_layout_mode : Bool,
) -> Unit {
  ignore(horizontal_layout_mode)
  node_label_cell_creator_create_node_label_cell_containers(
    node_context, only_inside,
  )

  // Node label cells require adapting LLabel to LabelCell's ElkLabel contract.
  // Port-driven size calculations are unaffected by this omission.
}
