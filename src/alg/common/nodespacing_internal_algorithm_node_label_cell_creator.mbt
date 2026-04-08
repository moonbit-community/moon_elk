///|
pub(all) suberror NodeLabelCellCreatorException {
  IllegalArgumentException(String)
} derive(Debug, ToJson)

///|
fn[T] node_label_cell_creator_raise_illegal_argument(
  message : String,
) -> T raise NodeLabelCellCreatorException {
  raise NodeLabelCellCreatorException::IllegalArgumentException(message)
}

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
fn node_label_cell_creator_retrieve_node_label_cell(
  node_context : NodeContext,
  node_label_location : NodeLabelLocation,
  horizontal_layout_mode : Bool,
) -> LabelCell raise NodeLabelCellCreatorException {
  let location_key = node_context_node_label_location_key(node_label_location)
  match node_context.node_label_cells.get(location_key) {
    Some(node_label_cell) => node_label_cell
    None => {
      let node_label_cell = new_label_cell_full(
        node_context.label_label_spacing,
        node_label_location,
        horizontal_layout_mode,
      )
      node_context.node_label_cells[location_key] = node_label_cell

      if node_label_location.is_inside_location() {
        let row = match node_label_location.container_row() {
          Some(value) => value
          None =>
            node_label_cell_creator_raise_illegal_argument(
              "inside node label location must provide container row",
            )
        }
        let col = match node_label_location.container_column() {
          Some(value) => value
          None =>
            node_label_cell_creator_raise_illegal_argument(
              "inside node label location must provide container column",
            )
        }
        grid_container_cell_set_cell(
          node_context.inside_node_label_container,
          row,
          col,
          Some(node_label_cell),
        )
      } else {
        let outside_side = node_label_location.outside_side()
        let container_cell = match
          node_context.outside_node_label_containers.get(
            node_context_port_side_key(outside_side),
          ) {
          Some(value) => value
          None =>
            node_label_cell_creator_raise_illegal_argument(
              "missing outside node label container",
            )
        }

        match outside_side {
          North | South => {
            node_label_cell.set_contributes_to_minimum_height(true)
            let col = match node_label_location.container_column() {
              Some(value) => value
              None =>
                node_label_cell_creator_raise_illegal_argument(
                  "outside north/south label must provide container column",
                )
            }
            container_cell.set_cell(col, Some(node_label_cell))
          }
          West | East => {
            node_label_cell.set_contributes_to_minimum_width(true)
            let row = match node_label_location.container_row() {
              Some(value) => value
              None =>
                node_label_cell_creator_raise_illegal_argument(
                  "outside west/east label must provide container row",
                )
            }
            container_cell.set_cell(row, Some(node_label_cell))
          }
          SideUndefined => ()
        }
      }

      node_label_cell
    }
  }
}

///|
fn node_label_cell_creator_handle_node_label(
  node_context : NodeContext,
  label : @core.ElkLabelAdapter,
  only_inside : Bool,
  horizontal_layout_mode : Bool,
) -> Unit raise NodeLabelCellCreatorException {
  let label_placement = if label.has_property_string_array(
      @core.node_labels_placement,
    ) {
    node_context_parse_node_label_placement(
      label.get_property_string_array(@core.node_labels_placement),
    )
  } else {
    node_context.node_label_placement
  }
  let label_location = node_label_location_from_node_label_placement(
    label_placement,
  )
  if label_location is UndefinedNodeLabelLocation {
    return
  }
  if only_inside && !label_location.is_inside_location() {
    return
  }

  node_label_cell_creator_retrieve_node_label_cell(
    node_context, label_location, horizontal_layout_mode,
  ).add_l_label(label)
}

///|
pub fn node_label_cell_creator_create_node_label_cells(
  node_context : NodeContext,
  only_inside : Bool,
  horizontal_layout_mode : Bool,
) -> Unit raise NodeLabelCellCreatorException {
  node_label_cell_creator_create_node_label_cell_containers(
    node_context, only_inside,
  )
  for label in node_context.node.get_labels() {
    node_label_cell_creator_handle_node_label(
      node_context, label, only_inside, horizontal_layout_mode,
    )
  }
}
